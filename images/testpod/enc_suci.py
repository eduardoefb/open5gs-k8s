#!/usr/bin/python3

# Reference: https://labs.p1sec.com/2020/06/26/5g-supi-suci-and-ecies/

# Needed libraries:
#   https://github.com/P1sec/pycrate.git
#   https://github.com/mitshell/CryptoMobile.git

import binascii
from pycrate_mobile.TS24501_IE import *
from CryptoMobile.ECIES import ECIES_UE,ECIES_HN,ECDH_SECP256R1
from pycrate_mobile.TS24008_IE import decode_bcd
from cryptography.hazmat.primitives import serialization
import argparse 
import sys

def generate_suci(scheme_id = None, hn_pubkey = None, imsi = None, supi = None, routing_indicator = None, key_id = None, plmn = None, msin = None, supi_type = None):
    # Generate the supi encrypted:
    if scheme_id == 0:
        suci = None

        suci_string = f"suci-{supi_type}-{plmn[:3]}-{plmn[3:5]}-{routing_indicator}-{scheme_id}-0-{msin}"
        
        #suci_string f"suci-0-724-17-0000-0-0-0000000001"
    elif scheme_id == 1:
        ue_ecies = ECIES_UE(profile='A')
    elif scheme_id == 2:
        ue_ecies = ECIES_UE(profile='B')
    
    print(supi)
    if scheme_id in [1, 2]:
        ue_ecies.generate_sharedkey(hn_pubkey)
        ue_pubkey, ue_encmsin, ue_mac = ue_ecies.protect(supi['Value']['Output'].to_bytes())
        suci = FGSIDSUPI(val={ 'Fmt': FGSIDFMT_IMSI, \
                            'Value': { 'PLMN': f"{plmn}", \
                            'ProtSchemeID': int(scheme_id), \
                            'Output': { 'ECCEphemPK': ue_pubkey, \
                            'CipherText': ue_encmsin, \
                            'MAC': ue_mac}}})

        # Request example:
        ue_key_text = binascii.hexlify(ue_pubkey).decode().upper()
        enc_msin_text = binascii.hexlify(ue_encmsin).decode().upper()
        mac_text = binascii.hexlify(ue_mac).decode().upper()

    print(f"\n####################SUPI###############\n{imsi}")

    if scheme_id in [1, 2]:
        print(f"\n####################SUCI###############\n{suci}")
    
    if scheme_id in [1, 2]:
        print(f"\n#################PRIVATE KEY###########\n{hn_privkey.hex()}")
        print(f"\n#################PUBLIC KEY############\n{hn_pubkey.hex()}")
        suci_string = f"suci-{supi_type}-{plmn[:3]}-{plmn[3:6]}-{routing_indicator}-{scheme_id}-{key_id}-{ue_key_text}{enc_msin_text}{mac_text}"

    net_string = f"5G:mnc{plmn[3:6]}.mcc{plmn[:3]}.3gppnetwork.org"
    print(f"\n############SUCI STRING################\n{suci_string}")

    json_file = open("suci.json", "w")
    json_str = """
    {
        "supiOrSuci": \"""" + str(suci_string) + """\",
        "servingNetworkName": \""""+ str(net_string) +"""\"
    }
    """
    json_file.write(json_str)
    json_file.close()
    return suci  

def decode_suci(scheme_id = None, hn_privkey = None, imsi = None, suci = None):
    # Validating the deconcealing:
    if scheme_id == 0:
        return None
    elif scheme_id == 1:
        hn_ecies = ECIES_HN(hn_privkey, profile='A')
    elif scheme_id == 2:
        hn_ecies = ECIES_HN(hn_privkey, profile='B')

    rx_suci = FGSIDSUPI()
    rx_suci.from_bytes(suci.to_bytes())

    # Then decrypts the MSIN part of the SUCI
    dec_msin = hn_ecies.unprotect(rx_suci['Value']['Output']['ECCEphemPK'].get_val(), rx_suci['Value']['Output']['CipherText'].get_val(), rx_suci['Value']['Output']['MAC'].get_val()) 

    # The original IMSI is retrieved from the PLMN ID and decrypted MSIN
    dec_imsi = suci['Value']['PLMN'].decode() + decode_bcd(dec_msin)
    print(f"\n##########DECONCEALED SUPI#############\n{dec_imsi}")
    return(dec_imsi)

def load_private_key(scheme_id = None, private_key_file = None):

    # Load private key from file and get its public key
    if scheme_id in [1, 2]:
        with open(str(private_key_file), "rb") as key_file:
            key_data = key_file.read()
        private_key = serialization.load_pem_private_key(key_data, password=None)

    if scheme_id == 0:
        hn_privkey = hn_pubkey = None

    elif scheme_id == 1:
        hn_privkey = private_key.private_bytes_raw()
        hn_pubkey = private_key.public_key().public_bytes_raw()
        
    elif scheme_id == 2:
        ec = ECDH_SECP256R1()
        ec.PrivKey = private_key
        hn_pubkey = bytes(ec.get_pubkey())
        hn_privkey = bytes(ec.get_privkey())  
    
    return hn_privkey, hn_pubkey



# Parser:
parser = argparse.ArgumentParser(description='Input data for open5gs')
parser.add_argument('--supi_type', type=str, required=True, help='SUPI type. 0 = IMSI, 1 = Network Access Identifier (NAI)')
parser.add_argument('--routing_indicator', type=str, required=True, help='Routing indicator. Ex: 0000')
parser.add_argument('--scheme_id', type=int, required=True, help='Scheme ID: 0 = null-scheme, 1 = Profile A, 2 = Profile B', choices=[0, 1, 2])
parser.add_argument('--key_id', type=int, required=True, help='Key ID')
parser.add_argument('--plmn', type=str, required=True, help='PLMN. Ex: 72417')
parser.add_argument('--msin', type=str, required=True, help='MSIN. Ex: 0000000001')
parser.add_argument('--key_file', type=str, required=False, help='Private key file')

args = parser.parse_args()

if args.scheme_id in [1, 2] and args.key_file is None:
    parser.error('--key_file is required for scheme_id 1 or 2')

supi_type = args.supi_type    
routing_indicator = args.routing_indicator
prot_scheme_id = args.scheme_id 
key_id = args.key_id
plmn = args.plmn
msin = args.msin 
priv_key = args.key_file

# IMSI
imsi = f"{plmn}{msin}"

# the MSIN part of the IMSI is set as the Output part of the SUPI
supi = FGSIDSUPI(val={ 'Fmt': FGSIDFMT_IMSI, \
                       'Value': {'PLMN': plmn, \
                       'Output': msin}}) 


# Load the private key and return the hn_priv and public keys
hn_privkey, hn_pubkey = load_private_key(scheme_id = prot_scheme_id, private_key_file = priv_key)

# Generate the suci encrypted
suci = generate_suci(scheme_id = prot_scheme_id, hn_pubkey = hn_pubkey, imsi = imsi, supi = supi, routing_indicator = routing_indicator, key_id = key_id, plmn = plmn, msin = msin, supi_type = supi_type)



# Decrypt suci
imsi = decode_suci(scheme_id = prot_scheme_id, hn_privkey = hn_privkey, suci = suci)

