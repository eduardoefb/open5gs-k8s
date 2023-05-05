FROM debian:11

LABEL maintainer="eduardoefb@gmail.com"

# Update packages and install kubectl:
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install lksctp-tools curl iproute2 iputils-ping traceroute net-tools dnsutils python3 python3-yaml tcpdump tshark netcat -y && \
    cd /tmp/ && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    mv /tmp/kubectl /usr/local/bin/kubectl

