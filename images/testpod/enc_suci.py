#!/usr/bin/python3

# Reference: https://labs.p1sec.com/2020/06/26/5g-supi-suci-and-ecies/

import binascii
from pycrate_mobile.TS24501_IE import *
from CryptoMobile.ECIES import ECIES_UE,ECIES_HN
from pycrate_mobile.TS24008_IE import decode_bcd
from cryptography.hazmat.primitives import serialization
import argparse 
import sys

# Parser:
parser = argparse.ArgumentParser(description='Input data for open5gs')
parser.add_argument('--supi_type', type=str, required=True, help='SUPI type. 0 = IMSI, 1 = Network Access Identifier (NAI)')
parser.add_argument('--routing_indicator', type=str, required=True, help='Routing indicator. Ex: 0000')
parser.add_argument('--scheme_id', type=int, required=True, help='Scheme ID: 0 = null-scheme, 1 = Profile A, 2 = Profile B', choices=[0, 1, 2])
parser.add_argument('--key_id', type=int, required=True, help='Key ID')
parser.add_argument('--plmn', type=str, required=True, help='PLMN. Ex: 72417')
parser.add_argument('--msin', type=str, required=True, help='MSIN. Ex: 0000000001')
parser.add_argument('--key_file', type=str, required=True, help='Private key file')

args = parser.parse_args()

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
                       'Value': {'PLMN': imsi[:5], \
                       'Output': imsi[5:]}}) 


# Load private key from file and get its public key
if prot_scheme_id == 1:
    with open(str(priv_key), "rb") as key_file:
        key_data = key_file.read()
    private_key = serialization.load_pem_private_key(key_data, password=None)

elif prot_scheme_id == 2:
    with open(str(priv_key), "rb") as key_file:
        pem_data = key_file.read()
        ec_privkey = serialization.load_pem_private_key(pem_data, password=None)    


if prot_scheme_id == 1:
    hn_privkey = private_key.private_bytes_raw()
    hn_pubkey = private_key.public_key().public_bytes_raw()
elif prot_scheme_id == 2:
    ec_pubkey = ec_privkey.public_key()
    ec_pubkey_bytes = ec_pubkey.public_bytes(
        encoding=serialization.Encoding.X962,
        format=serialization.PublicFormat.CompressedPoint
    )

    hn_pubkey = bytes(ec_pubkey_bytes)

if prot_scheme_id == 1:
    ue_ecies = ECIES_UE(profile='A')
elif prot_scheme_id == 2:
    ue_ecies = ECIES_UE(profile='B')

ue_ecies.generate_sharedkey(hn_pubkey)
ue_pubkey, ue_encmsin, ue_mac = ue_ecies.protect(supi['Value']['Output'].to_bytes())

# Request example:
ue_key_text = binascii.hexlify(ue_pubkey).decode().upper()
enc_msin_text = binascii.hexlify(ue_encmsin).decode().upper()
mac_text = binascii.hexlify(ue_mac).decode().upper()

suci_string = f"suci-{supi_type}-{plmn[:3]}-{plmn[3:5]}-{routing_indicator}-{prot_scheme_id}-{key_id}-{ue_key_text}{enc_msin_text}{mac_text}"
net_string = f"5G:mnc0{plmn[3:5]}.mcc{plmn[:3]}.3gppnetwork.org"

json_file = open("suci.json", "w")
json_str = """
{
    "supiOrSuci": \"""" + str(suci_string) + """\",
    "servingNetworkName": \""""+ str(net_string) +"""\"
}
"""

json_file.write(json_str)
json_file.close()


