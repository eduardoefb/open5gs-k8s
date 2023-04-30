#!/usr/bin/python3

import yaml, sys, os

gnodeb_ip = sys.argv[1]
values_file = "/opt/open5gs/config/subscribers.yaml"

with open(values_file, 'r') as f:
    values = yaml.safe_load(f)

pod_id = int(str(os.environ['HOSTNAME']).split("-")[-1])

subscriber = values[pod_id]
mcc = subscriber["imsi"][0:3]

# MNC with len=2
mnc = subscriber["imsi"][3:5]

# MNC with len=3
# mnc = subscriber["imsi"][3:6]


fp = open("/etc/subscriber.yaml", "w")

fp.write("""
supi: 'imsi-""" + str(subscriber["imsi"]) + """'
mcc: '""" + str(mcc) + """'
mnc: '""" + str(mnc) + """'
key: '""" + str(subscriber["key"]) + """'
op: '""" + str(subscriber["opc"]) + """'
opType: 'OPC'
amf: '""" + str(subscriber["amf"]) + """'
imei: '""" + str(subscriber["imei"]) + """'
imeiSv: '""" + str(subscriber["imeisv"]) + """'
gnbSearchList:
  - """ + str(gnodeb_ip) + """
uacAic:
  mps: false
  mcs: false
uacAcc:
  normalClass: 0
  class11: false
  class12: false
  class13: false
  class14: false
  class15: false
sessions:
  - type: 'IPv4'
    apn: 'internet'
    slice:
      sst: """ + str(subscriber["slice"]["sst"]) + """
configured-nssai:
  - sst: """ + str(subscriber["slice"]["sst"]) + """
default-nssai:
  - sst: """ + str(subscriber["slice"]["sst"]) + """
    sd: 1
integrity:
  IA1: true
  IA2: true
  IA3: true
ciphering:
  EA1: true
  EA2: true
  EA3: true
integrityMaxRate:
  uplink: 'full'
  downlink: 'full'
""")

fp.close()