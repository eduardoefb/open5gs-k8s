FROM ubuntu:22.04 AS builder

# Update package and install needed files:
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install software-properties-common curl cmake build-essential make g++ libsctp-dev lksctp-tools iproute2 git 

# Download ueramsim and build it:
RUN cd /opt && git clone https://github.com/aligungr/UERANSIM && \
    cd /opt/UERANSIM && \
    git checkout && \
    cd /opt/UERANSIM && \
    make

FROM ubuntu:22.04

# Update packages:
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install lksctp-tools curl iproute2 iputils-ping traceroute net-tools dnsutils -y

# Copy files:
COPY --from=builder /opt/UERANSIM /opt/UERANSIM    
COPY start_gnodeb.sh /opt/start_gnodeb.sh
RUN chmod +x /opt/start_gnodeb.sh
COPY start_ue.sh /opt/start_ue.sh
RUN chmod +x /opt/start_ue.sh

# Download kubectl
RUN cd /tmp/ && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    mv /tmp/kubectl /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl
