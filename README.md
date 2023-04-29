
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
kubectl exec -it open5gs-ue-0 -c open5gs-ue -- ip route
```

Example:
```log
~> kubectl exec -it open5gs-ue-0 -c open5gs-ue -- ip route
default dev uesimtun0 scope link 
default via 169.254.1.1 dev eth0 metric 10 
10.233.0.1 via 169.254.1.1 dev eth0 
10.233.98.183 via 169.254.1.1 dev eth0 
169.254.1.1 dev eth0 scope link 
~> 

Check connectivity with the external network:
```shell
kubectl exec -it open5gs-ue-0 -c open5gs-ue -- traceroute -n 1.1.1.1
```

The route shoud be via UPF's  ip `10.45.0.1`:
```log
~> kubectl exec -it open5gs-ue-0 -c open5gs-ue -- traceroute -n 1.1.1.1
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

To be able to connect to the webui, you must add the istio's ip to the /etc/hosts with the virtualservices fqdns:

```shell
kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
kubectl get virtualservice
```

## Example http2 verifications


```shell

## UDM:
nghttp -v http://udm.open5gs.int/nudm-sdm/v2/imsi-724170000000001/am-data  -H':method: GET' -H'user-agent: AMF'
curl -v http://udm.open5gs.int/nudm-sdm/v2/imsi-724170000000001/am-data  -H':method: GET' -H'user-agent: AMF'
## UDM Via scp:
nghttp -v http://scp.open5gs.int/nudm-sdm/v2/imsi-724170000000001/am-data  \
   -H "3gpp-sbi-target-apiroot: http://open5gs-udm:8080" \
   -H':method: GET' -H'user-agent: AMF'

curl -v http://scp.open5gs.int/nudm-sdm/v2/imsi-724170000000001/am-data  \
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
