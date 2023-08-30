FROM debian:11

LABEL maintainer="eduardoefb@gmail.com"

ENV OPEN5GS_UID=1024
ENV OPEN5GS_GID=1024

# Update package
RUN  DEBIAN_FRONTEND=noninteractive apt-get update && \
     DEBIAN_FRONTEND=noninteractive apt-get -y install curl \
            software-properties-common \
            iproute2 \
            nghttp2 \
            net-tools \
            gcc \
            g++ \
            make \
            build-essential \
            vim \
            iptables\
            python3 \
            python3-setuptools \
            git \
            dos2unix \
            libpython3-all-dev \
            python3-pip \
            iputils-ping \
            traceroute \
            dnsutils

# Install kubectl
RUN cd /tmp/ && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    mv /tmp/kubectl /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl

# Install needed modules
RUN pip3 install cryptography

# Install the required libraries for suci concealing for tests
RUN cd /tmp/ && \
    git clone https://github.com/P1sec/pycrate.git &&  \
    cd pycrate && \
    git checkout && \
    python3 setup.py install

RUN cd /tmp/ && \
    git clone https://github.com/mitshell/CryptoMobile.git && \
    cd CryptoMobile && \
    git checkout && \
    python3 setup.py install


RUN useradd open5gs -s /bin/bash
# Change UID and GID of Open5GS user:    
RUN groupmod open5gs -g ${OPEN5GS_GID} && \
    usermod open5gs -u ${OPEN5GS_UID} -G open5gs && \
    mkdir /home/open5gs && \
    usermod open5gs -d /home/open5gs/

# Copy Needed files
COPY concealing_tool.py /home/open5gs/concealing_tool.py

# Set ownership and permissions of Open5GS directories and files:
RUN chown -R open5gs:open5gs /home/open5gs && \
    chmod +x /home/open5gs/concealing_tool.py
