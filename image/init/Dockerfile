FROM debian:11

LABEL maintainer="eduardoefb@gmail.com"

ENV OPEN5GS_UID=1024
ENV OPEN5GS_GID=1024

# Update package and install needed files and download kubectl:
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install curl netcat dnsutils && \
    cd /tmp/ && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    mv /tmp/kubectl /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl && \   
    useradd open5gs && \ 
    groupmod open5gs -g ${OPEN5GS_GID} && \
    usermod open5gs -u ${OPEN5GS_UID} -G open5gs && \
    mkdir /home/open5gs && \
    usermod open5gs -d /home/open5gs/    

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
    chmod +x /opt/wait_mongodb.sh && \
    chown open5gs:open5gs /opt/wait*.sh

