#!/usr/bin/python3

import pymongo, yaml, sys, os

db_url = "mongodb://" + str(os.environ['PREFIX']) + "-mongodb:27017"
values_file = "/opt/open5gs/subscribers.yaml"


with open(values_file, 'r') as f:
    values = yaml.safe_load(f)

client = pymongo.MongoClient(db_url)
db = client["open5gs"]
collection = db["subscribers"]

# Clear collection:
collection.delete_many({})

for p in values:
    doc =   {
                "imsi": p["imsi"],
                "msisdn": [p["msisdn"]],
                "imeisv": [p["imeisv"]],
                "mme_host": [],
                "mm_realm": [],
                "purge_flag": [],
                "slice":[
                {
                    "sst": int(p["slice"]["sst"]),
                    "default_indicator": True, 
                        "session": [
                        {
                            "name" : "internet",
                            "type" : int(3),
                            "qos" : 
                            { "index": int(9), 
                                "arp": 
                                {
                                    "priority_level" : int(8),
                                    "pre_emption_capability": int(1),
                                    "pre_emption_vulnerability": int(2)
                                }
                            },
                            "ambr": 
                            {
                                "downlink": 
                                {
                                    "value": int(p["slice"]["dl_ambr"]),
                                    "unit": int(0)
                                },
                                "uplink":
                                {
                                    "value": int(p["slice"]["ul_ambr"]),
                                    "unit": int(0)
                                }
                            },
                            "pcc_rule": []
                        }]
                    }], 
                    "security": 
                    {
                        "k" : str(p["key"]),
                        "op" : None,
                        "opc" : str(p["opc"]),
                        "amf" : str(p["amf"]),
                    },
                    "ambr" : 
                    {
                        "downlink" : { "value": int(1000000000), "unit": int(0)},
                        "uplink" : { "value": int(1000000000), "unit": int(0)}
                    },
                    "access_restriction_data": 32,
                    "network_access_mode": 0,
                    "subscribed_rau_tau_timer": 12,
                    "__v": 0
                }         
    collection.insert_one(doc)
    print("Inserted document ID:", doc["_id"])      

sys.exit(0)