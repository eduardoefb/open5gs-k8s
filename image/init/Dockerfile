FROM debian:10 

# Update package and install needed files:
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install curl netcat dnsutils

# Download kubectl
RUN cd /tmp/ && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    mv /tmp/kubectl /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl

# Copy scripts
COPY wait_amf.sh /opt/wait_amf.sh
COPY wait_gnodeb.sh /opt/wait_gnodeb.sh
COPY wait_nrf.sh /opt/wait_nrf.sh
COPY wait_scp.sh /opt/wait_scp.sh
COPY wait_scp_service.sh /opt/wait_scp_service.sh
COPY wait_scp.sh /opt/wait_upf.sh
COPY wait_mongodb.sh /opt/wait_mongodb.sh
COPY vars.sh /opt/vars.sh

# Allow execution:
RUN chmod +x /opt/wait_amf.sh  && \
    chmod +x /opt/wait_gnodeb.sh  && \
    chmod +x /opt/wait_nrf.sh  && \
    chmod +x /opt/wait_scp.sh  && \
    chmod +x /opt/wait_scp_service.sh  && \
    chmod +x /opt/wait_upf.sh  && \
    chmod +x /opt/wait_mongodb.sh

