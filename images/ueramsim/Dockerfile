FROM ubuntu:22.04 AS builder

LABEL maintainer="eduardoefb@gmail.com"

# Update package and install needed files:
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install software-properties-common curl cmake build-essential make g++ libsctp-dev lksctp-tools iproute2 git 

# Download ueramsim and build it:
WORKDIR /opt
RUN git clone https://github.com/aligungr/UERANSIM && \
    cd UERANSIM && \
    git checkout && \    
    make

FROM ubuntu:22.04

LABEL maintainer="eduardoefb@gmail.com"

# Update packages and install kubectl:
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install lksctp-tools curl iproute2 iputils-ping traceroute net-tools dnsutils python3 python3-yaml -y && \
    cd /tmp/ && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    mv /tmp/kubectl /usr/local/bin/kubectl

# Copy files:
COPY --from=builder --chown=root:root /opt/UERANSIM /opt/UERANSIM    
COPY --chown=root:root start_gnodeb.sh /opt/start_gnodeb.sh
COPY --chown=root:root gnodeb_probe.sh /opt/gnodeb_probe.sh
COPY --chown=root:root subscriber_config.py /opt/subscriber_config.py
COPY --chown=root:root start_ue.sh /opt/start_ue.sh

RUN chmod +x /opt/start_ue.sh /opt/start_gnodeb.sh /usr/local/bin/kubectl /opt/gnodeb_probe.sh /opt/subscriber_config.py

