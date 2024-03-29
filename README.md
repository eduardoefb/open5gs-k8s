
# Open5gs on kubernetes

## Overview
This guide explains how to set up and run Open5GS on Kubernetes. It includes instructions for creating the Open5GS Docker image, as well as deploying and accessing the Open5GS Kubernetes cluster.

## Prerequisites

Before you get started, make sure you have the following:

- Kubernetes cluster (version 1.16 or later) and istio
- `kubectl` command line tool
- A valid image registry 
- Podman and buildah installation

## Image Creation
First, build the images executing the `run.sh` with the option `build`:

```shell
cd images
bash run.sh build
```
If authentication is needed, it will ask the credentials during the script execution.


## Open5gs and ueramsim deployment
In order to deploy ueramsim and open5gs, execute the `run.sh`  script  with `deploy` option:
```shell
bash run.sh deploy
```

## Verify operation
Once all pods up and running, you can verify in the subscriber's pod the 
```bash
kubectl exec -it open5gs-ue-0 -c open5gs-ue -- ip addr
```

Example:
```log
~> kubectl exec -it open5gs-ue-0 -c open5gs-ue -- ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
3: eth0@if122: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1400 qdisc noqueue state UP group default 
    link/ether 9a:b7:2d:33:2f:d1 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.233.110.185/32 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::98b7:2dff:fe33:2fd1/64 scope link 
       valid_lft forever preferred_lft forever
5: uesimtun0: <POINTOPOINT,PROMISC,NOTRAILERS,UP,LOWER_UP> mtu 1400 qdisc pfifo_fast state UNKNOWN group default qlen 500
    link/none 
    inet 10.45.0.3/32 scope global uesimtun0
       valid_lft forever preferred_lft forever
    inet6 fe80::90a3:d338:5fe9:fec1/64 scope link stable-privacy 
       valid_lft forever preferred_lft forever
~> 

Verify the routing table:
```shell
PREFIX="open5gs"
kubectl exec -it ${PREFIX}-ue-0 -c ${PREFIX}-ue -- ip route
```

Example:
```log
~> kubectl exec -it ${PREFIX}-ue-0 -c ${PREFIX}-ue -- ip route
default dev uesimtun0 scope link 
default via 169.254.1.1 dev eth0 metric 10 
10.233.0.1 via 169.254.1.1 dev eth0 
10.233.98.183 via 169.254.1.1 dev eth0 
169.254.1.1 dev eth0 scope link 
~> 

Check connectivity with the external network:
```shell
PREFIX="open5gs"
kubectl exec -it ${PREFIX}-ue-0 -c ${PREFIX}-ue -- traceroute -n 1.1.1.1
```

The route shoud be via UPF's  ip `10.45.0.1`:
```log
~> kubectl exec -it ${PREFIX}-ue-0 -c ${PREFIX}-ue -- traceroute -n 1.1.1.1
traceroute to 1.1.1.1 (1.1.1.1), 30 hops max, 60 byte packets
 1  10.45.0.1  4.965 ms  4.909 ms  4.853 ms  
 2  10.20.0.47  4.867 ms  4.901 ms  4.829 ms
 3  10.20.0.1  5.319 ms  5.268 ms  5.229 ms
 4  10.8.0.1  5.659 ms  5.647 ms  5.613 ms
 ....
 ....
16  1.1.1.1  11.620 ms  10.642 ms  10.597 ms
~>
```

To connect to the web UI, you need to add the IP address of Istio to the /etc/hosts file along with the fully qualified domain names (FQDNs) of the virtual services.

```shell
kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
kubectl get virtualservice
```

Alternatively, you can use the following commands to generate the /etc/hosts entry (replace the "open5gs" namespace with your own namespace):
```shell
ingress_ip=`kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}'`
for i in `kubectl -n open5gs get virtualservice | grep -v NAME | awk '{print $1}'`; do
    hname=`kubectl -n open5gs get virtualservice ${i} -o jsonpath='{.spec.hosts[0]}'`
    echo "${ingress_ip} ${hname}"   
done

```

## Example http2 verifications
The follwing command can be executed inside any open5gs pod (amf/ausf/pcf/nrf... etc):

- UDM: Show am-data from subscriber:
```shell
PREFIX="open5gs"
SUPI="724170000000001"
kubectl exec -it ${PREFIX}-amf-0 -it -- \
   nghttp http://${PREFIX}-udm:8080/nudm-sdm/v2/imsi-${SUPI}/am-data  \
   -H':method: GET' \
   -H'user-agent: AMF'
```

Example:
```log
kubectl exec -it ${PREFIX}-amf-0 -it -- \
   nghttp http://${PREFIX}-udm:8080/nudm-sdm/v2/imsi-${SUPI}/am-data  \
   -H':method: GET' \
   -H'user-agent: AMF'
{
	"subscribedUeAmbr":	{
		"uplink":	"976562 Kbps",
		"downlink":	"976562 Kbps"
	},
	"nssai":	{
		"defaultSingleNssais":	[{
				"sst":	1
			}]
	}
}~> 
```

- UDM - Show am-data from subscriber via SCP:
```shell
PREFIX="open5gs"
SUPI="724170000000001"
kubectl exec -it ${PREFIX}-amf-0 -it -- \
   nghttp http://${PREFIX}-scp:8080/nudm-sdm/v2/imsi-${SUPI}/am-data  \
   -H "3gpp-sbi-target-apiroot: http://${PREFIX}-udm:8080" \
   -H':method: GET' \
   -H'user-agent: AMF'
```
Example:
```log
kubectl exec -it ${PREFIX}-amf-0 -it -- \
   nghttp http://${PREFIX}-scp:8080/nudm-sdm/v2/imsi-${SUPI}/am-data  \
   -H "3gpp-sbi-target-apiroot: http://${PREFIX}-udm:8080" \
   -H':method: GET' \
   -H'user-agent: AMF'
{
	"subscribedUeAmbr":	{
		"uplink":	"976562 Kbps",
		"downlink":	"976562 Kbps"
	},
	"nssai":	{
		"defaultSingleNssais":	[{
				"sst":	1
			}]
	}
}
```

- UDR - Get subscription data:
```shell
PREFIX="open5gs"
SUPI="724170000000001"
kubectl exec -it `kubectl get pod -l app=${PREFIX}-udm -o jsonpath='{.items[0].metadata.name}'` -it -- \
   nghttp http://${PREFIX}-udr:8080/nudr-dr/v1/subscription-data/imsi-${SUPI}/authentication-data/authentication-subscription  \
   -H':method: GET' \
   -H'user-agent: UDM'
```

Example:
```log
kubectl exec -it ${PREFIX}-udm-0 -it -- \
   nghttp http://${PREFIX}-udr:8080/nudr-dr/v1/subscription-data/imsi-${SUPI}/authentication-data/authentication-subscription  \
   -H':method: GET' \
   -H'user-agent: UDM'
{
	"authenticationMethod":	"5G_AKA",
	"encPermanentKey":	"465b5ce8b199b49faa5f0a2ee238a6b0",
	"sequenceNumber":	{
		"sqn":	"000000000081"
	},
	"authenticationManagementField":	"8000",
	"encOpcKey":	"e8ed289deba952e4283b54e88e6183c0"
}
```

- UDR - Get subscription data scp:
```shell
PREFIX="open5gs"
SUPI="724170000000001"
kubectl exec -it `kubectl get pod -l app=${PREFIX}-udm -o jsonpath='{.items[0].metadata.name}'` -it -- \
   nghttp http://${PREFIX}-scp:8080/nudr-dr/v1/subscription-data/imsi-${SUPI}/authentication-data/authentication-subscription  \
   -H':method: GET' \
   -H "3gpp-sbi-target-apiroot: http://${PREFIX}-udr:8080" \
   -H'user-agent: UDM'
```

Example:
```log
~> kubectl exec -it ${PREFIX}-udm-0 -it -- \
   nghttp http://${PREFIX}-scp:8080/nudr-dr/v1/subscription-data/imsi-${SUPI}/authentication-data/authentication-subscription  \
   -H':method: GET' \
   -H "3gpp-sbi-target-apiroot: http://${PREFIX}-udr:8080" \
   -H'user-agent: UDM'
{
	"authenticationMethod":	"5G_AKA",
	"encPermanentKey":	"465b5ce8b199b49faa5f0a2ee238a6b0",
	"sequenceNumber":	{
		"sqn":	"000000000081"
	},
	"authenticationManagementField":	"8000",
	"encOpcKey":	"e8ed289deba952e4283b54e88e6183c0"
}~> 
```

- NRF - Get subscription info instances:

AMF asking SMF's service name: nsmf-pdusession to the NRF
```shell
PREFIX="open5gs"
kubectl exec -it ${PREFIX}-amf-0 -it -- \
   nghttp http://${PREFIX}-nrf:8080/nnrf-disc/v1/nf-instances?service-names=nsmf-pdusession\&target-nf-type=SMF\&requester-nf-type=AMF \
   -H':method: GET' \
   -H'user-agent: AMF'
```

Example:
```log
kubectl exec -it ${PREFIX}-amf-0 -it -- \
   nghttp http://${PREFIX}-nrf:8080/nnrf-disc/v1/nf-instances?service-names=nsmf-pdusession\&target-nf-type=SMF\&requester-nf-type=AMF \
   -H':method: GET' \
   -H'user-agent: AMF'
{
	"validityPeriod":	3600,
	"nfInstances":	[{
			"nfInstanceId":	"603cd366-e6b2-41ed-8469-13efca7cfe0e",
			"nfType":	"SMF",
			"nfStatus":	"REGISTERED",
			"heartBeatTimer":	10,
			"ipv4Addresses":	["10.233.110.184"],
			"allowedNfTypes":	["AMF", "SCP"],
			"priority":	0,
			"capacity":	100,
			"load":	0,
			"nfServices":	[{
					"serviceInstanceId":	"60495cda-e6b2-41ed-8469-13efca7cfe0e",
					"serviceName":	"nsmf-pdusession",
					"versions":	[{
							"apiVersionInUri":	"v1",
							"apiFullVersion":	"1.0.0"
						}],
					"scheme":	"http",
					"nfServiceStatus":	"REGISTERED",
					"ipEndPoints":	[{
							"ipv4Address":	"10.233.110.184",
							"port":	8080
						}],
					"allowedNfTypes":	["AMF"],
					"priority":	0,
					"capacity":	100,
					"load":	0
				}],
			"nfProfileChangesSupportInd":	true
		}]
}~> 

```

AMF asking UDM's service name: nudm-uecm  to the NRF
```shell
PREFIX="open5gs"
kubectl exec -it ${PREFIX}-amf-0 -it -- \
   nghttp http://${PREFIX}-nrf:8080/nnrf-disc/v1/nf-instances?service-names=nudm-uecm\&target-nf-type=UDM\&requester-nf-type=AMF \
   -H':method: GET' \
   -H'user-agent: AMF'
```

Example:
```log
kubectl exec -it ${PREFIX}-amf-0 -it -- \
   nghttp http://${PREFIX}-nrf:8080/nnrf-disc/v1/nf-instances?service-names=nudm-uecm\&target-nf-type=UDM\&requester-nf-type=AMF \
   -H':method: GET' \
   -H'user-agent: AMF'
{
	"validityPeriod":	3600,
	"nfInstances":	[{
			"nfInstanceId":	"5efd22a8-e6b2-41ed-84a7-e50a4db3e9ac",
			"nfType":	"UDM",
			"nfStatus":	"REGISTERED",
			"heartBeatTimer":	10,
			"ipv4Addresses":	["10.233.110.186"],
			"allowedNfTypes":	["AMF", "SMF", "AUSF", "SCP"],
			"priority":	0,
			"capacity":	100,
			"load":	0,
			"nfServices":	[{
					"serviceInstanceId":	"5efd7bae-e6b2-41ed-84a7-e50a4db3e9ac",
					"serviceName":	"nudm-uecm",
					"versions":	[{
							"apiVersionInUri":	"v1",
							"apiFullVersion":	"1.0.0"
						}],
					"scheme":	"http",
					"nfServiceStatus":	"REGISTERED",
					"ipEndPoints":	[{
							"ipv4Address":	"10.233.110.186",
							"port":	8080
						}],
					"allowedNfTypes":	["AMF"],
					"priority":	0,
					"capacity":	100,
					"load":	0
				}],
			"nfProfileChangesSupportInd":	true
		}]
}
```


#### Testing profile A/B  with concealed suci
To test the deconcealing sucis in profiles A and B, connect to the tsh pod:
```shell
PREFIX="open5gs"
kubectl exec -it ${PREFIX}-tsh-0 -- bash
cd ~
```

- Profile A:
To list the key ids for profile A, execute the follwing commands:
```shell
udm_pod_name=`kubectl get pod -l app=${PREFIX}-udm -o jsonpath='{.items[0].metadata.name}'` 
kubectl exec -it ${udm_pod_name} -- cat /etc/open5gs/udm.yaml
kubectl exec -it ${udm_pod_name} -- cat /etc/open5gs/udm.yaml | grep -1 "scheme: 1"
```

Testing with key id 1:
```shell
key_id=1

udm_pod_name=`kubectl get pod -l app=${PREFIX}-udm -o jsonpath='{.items[0].metadata.name}'` 

key_file=`kubectl exec -it ${udm_pod_name} -- cat /etc/open5gs/udm.yaml | grep -A2 " id: ${key_id}" | grep "key: " | awk '{print $NF}' | sed 's/\x0d//g'`

# Retrieve the private key from the UDM pod:
kubectl exec -it  ${udm_pod_name} -- cat ${key_file}  > /tmp/private_key.pem

# Obtain the public key from the private key:
openssl pkey -in /tmp/private_key.pem -pubout -outform PEM -out /tmp/public_key.pem

# Retrieve the bytes for both the public and private keys:
openssl pkey -in /tmp/private_key.pem -text -noout

# SUPI concealing using the public key
cd ~/
python3 concealing_tool.py --conceal \
   --supi_type 0 \
   --routing_indicator 0000 \
   --scheme_id 1 \
   --key_id ${key_id} \
   --plmn 72417 \
   --msin 0000000001 \
   --json_file suci_json.json \
   --public_key_file /tmp/public_key.pem

# Deconcealing SUCI to SUPI using the private key
python3 concealing_tool.py \
   --deconceal \
   --suci_string suci-0-724-17-0000-1-1-8C9B6F15816ED9DD6D4463DD07A319D42618B2E46FEA1233D21599E55B851A49F53FD8D00F98172357C0AD2361  \
   --private_key_file /tmp/private_key.pem

# Or, from the json file:  
python3 concealing_tool.py \
   --deconceal \
   --json_file suci_json.json --private_key_file /tmp/private_key.pem

# Review the JSON file created by the script:
cat suci_json.json

# Send the authentication for the concealed SUCI:
nghttp -v http://${PREFIX}-ausf:8080/nausf-auth/v1/ue-authentications \
	-H':method: POST' \
	-H'user-agent: AMF' \
	-H 'content-type: application/json'  \
	-d suci_json.json

```

- Profile B:
To list the key ids for profile B, execute the follwing commands:
```shell
udm_pod_name=`kubectl get pod -l app=${PREFIX}-udm -o jsonpath='{.items[0].metadata.name}'` 
kubectl exec -it ${udm_pod_name} -- cat /etc/open5gs/udm.yaml | grep -1 "scheme: 2"
```

Testing with key id 2:
```shell
key_id=2
udm_pod_name=`kubectl get pod -l app=${PREFIX}-udm -o jsonpath='{.items[0].metadata.name}'` 

key_file=`kubectl exec -it ${udm_pod_name} -- cat /etc/open5gs/udm.yaml | grep -A2 " id: ${key_id}" | grep "key: " | awk '{print $NF}' | sed 's/\x0d//g'`

# Retrieve the private key from the UDM pod:
kubectl exec -it  ${udm_pod_name} -- cat ${key_file}  > /tmp/private_key.pem

# Obtain the compressed public key from the private key:
openssl ec -in /tmp/private_key.pem -pubout -conv_form compressed -out /tmp/public_key.pem

# Retrieve the bytes for both the public (compressed) and private keys:
openssl ec -in /tmp/private_key.pem -text -noout -conv_form compressed

# SUPI concealing using the public key
cd ~/
python3 concealing_tool.py --conceal \
   --supi_type 0 \
   --routing_indicator 0000 \
   --scheme_id 2 \
   --key_id ${key_id} \
   --plmn 72417 \
   --msin 0000000001 \
   --json_file suci_json.json \
   --public_key_file /tmp/public_key.pem

# Decode SUCI string to SUPI using a private key: (replace the suci string for the generated string in the previous commands)
python3 concealing_tool.py --deconceal \
   --suci_string suci-0-724-17-0000-2-2-02165E5EA0C10ACB09FED88D3A8185683AE27B588B8EBB72DBE30B1B99D997CB05A33366264F259A5A6CF1FAD8BA  \
   --private_key_file /tmp/private_key.pem    

# Or, from the json file:  
python3 concealing_tool.py --deconceal \
   --json_file suci_json.json --private_key_file /tmp/private_key.pem 

# Review the JSON file created by the script:	
cat suci_json.json

# Send the authentication for the concealed SUCI:
nghttp -v http://${PREFIX}-ausf:8080/nausf-auth/v1/ue-authentications  \
	-H':method: POST' \
	-H'user-agent: AMF' \
	-H 'content-type: application/json'  \
	-d suci_json.json
```
## Debugging nodes:

To debug nodes (execute tcpdump, for example), it can be done by executing the follwing procedure:

```shell
kubectl debug node/k8s-worker-0 -it --image=debian:11
```