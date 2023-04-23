
# Open5gs on kubernetes

## Overview
This guide explains how to set up and run Open5GS on Kubernetes. It includes instructions for creating the Open5GS Docker image, as well as deploying and accessing the Open5GS Kubernetes cluster.

## Prerequisites

Before you get started, make sure you have the following:

- Kubernetes cluster (version 1.16 or later) and istio
- `kubectl` command line tool
- Podman installation

## Image Creation
First, navigate to the `image` directory and run the `create_image.sh` script to create the Open5GS and UERAMSIM images.

```shell
cd image
bash create_image.sh
```
If authentication is needed, it will ask the credentials during the script execution.


## Open5gs and ueramsim deployment
In order to deploy ueramsim and open5gs, create the namespace, ex: `open5gs`  and set it as default:
```shell
kubectl create namespace open5gs
kubectl config set-context --current --namespace=open5gs
```

Label the open5gs namespace with istio-injection=enabled so that Istio is used as the default:
```shell
kubectl label namespace open5gs istio-injection=enabled
```

Execute the script namespace_and_secrets.sh to create the necessary secrets:
```shell
bash namespace_and_secrets.sh
```

## Install open5gs and ueramsim
Once the above steps are completed, you can proceed to deploy ueramsim and open5gs using the Kubernetes deployment files.
```shell
helm install open5gs open5gs
```

## Configure /etc/hosts file
To ensure proper functioning of your system, it's essential to configure your /etc/hosts file with the external IP of the istio-ingressgateway and the hostnames created for your virtual service. This will allow your system to correctly route traffic to the appropriate destination.
```shell
kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
kubectl get virtualservice
```

## Create the subscriber
To begin, access the MongoDB URL that corresponds to the virtual service named <prefix>-mongodb-vs. Once you've accessed the URL, your next step will be to create the subscribers. It's crucial to ensure that the subscriber you define in your helm chart's values.yaml file is created precisely as specified to guarantee the proper functioning of the system. So, be sure to double-check your subscriber's configuration before proceeding.

The default user and password is admin/1423


## Delete ue pod
After creating the subscriber, delete the UE pod to prompt a reconnection attempt to the 5G network. Then, carefully monitor the process to ensure that the connection is reestablished correctly.

Example:
```shell
kubectl logs -f open5gs-ue-bcc56fb8f-kwtqf
```

## Curl tests:
```shell

## UDM:
nghttp -v http://udm.open5gs.int/nudm-sdm/v2/imsi-724170000000001/am-data  -H':method: GET' -H'user-agent: AMF'

## UDM Via scp:
nghttp -v http://scp.open5gs.int/nudm-sdm/v2/imsi-724170000000001/am-data  \
   -H "3gpp-sbi-target-apiroot: http://open5gs-udm:8080" \
   -H':method: GET' -H'user-agent: AMF'


## UDR:
nghttp -v http://udr.open5gs.int/nudr-dr/v1/subscription-data/imsi-724170000000001/authentication-data/authentication-subscription  \
-H':method: GET' -H'user-agent: UDM'

## UDR Via SCP:
nghttp -v http://scp.open5gs.int/nudr-dr/v1/subscription-data/imsi-724170000000001/authentication-data/authentication-subscription  \
-H':method: GET' -H'user-agent: UDM' \
-H "3gpp-sbi-target-apiroot: http://open5gs-udr:8080"


### Check NRF:
nghttp -v 'http://nrf.open5gs.int/nnrf-disc/v1/nf-instances?service-names=nsmf-pdusession&target-nf-type=SMF&requester-nf-type=AMF'  \
-H':method: GET' -H'user-agent: AMF'


nghttp 'http://nrf.open5gs.int/nnrf-disc/v1/nf-instances?target-nf-type=UDR&requester-nf-type=PCF'
nghttp 'http://nrf.open5gs.int/nnrf-disc/v1/nf-instances?target-nf-type=UDM&requester-nf-type=AMF'
nghttp 'http://nrf.open5gs.int/nnrf-disc/v1/nf-instances?target-nf-type=UDRrequester-nf-type=UDM'

```
