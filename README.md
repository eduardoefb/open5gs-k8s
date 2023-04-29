
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

## Configure /etc/hosts file
To ensure proper functioning of your system, it's essential to configure your /etc/hosts file with the external IP of the istio-ingressgateway and the hostnames created for your virtual service. This will allow your system to correctly route traffic to the appropriate destination.
```shell
kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
kubectl get virtualservice
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
