FROM ubuntu:20.04

# Update package
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# Install required packages:
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install curl software-properties-common iproute2 nghttp2 net-tools gcc g++ make build-essential vim

# Install Open5GS from PPA repository:
RUN DEBIAN_FRONTEND=noninteractive add-apt-repository ppa:open5gs/latest && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install open5gs

# Install Node.js from NodeSource repository:
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install nodejs

# Change UID and GID of Open5GS user:    
RUN groupmod open5gs -g 1024 && \
    usermod open5gs -u 1024 -G open5gs && \
    mkdir /home/open5gs && \
    usermod open5gs -d /home/open5gs/

# Set ownership and permissions of Open5GS directories and files:
RUN chown -R open5gs:open5gs /etc/open5gs/ && \
    chown -R open5gs:open5gs /var/log/open5gs/ && \
    chown -R open5gs:open5gs /var/lib/mongodb/ && \
    chown -R open5gs:open5gs /usr/bin/open5gs* && \
    chown -R open5gs:open5gs /home/open5gs/ && \
    chown -R open5gs:open5gs /var/log/mongodb/

# Create needed directories    
RUN mkdir -p /run/mongodb

# Copy Needed files
COPY mongodb.conf /etc/mongodb.conf
COPY install_npm.sh /opt/install_npm
COPY post_install_npm.sh /opt/post_install_npm
COPY start_mongodb.sh /opt/start_mongodb.sh
COPY start_app.sh /opt/start_app.sh

# Install npm:
RUN cd /opt/ && bash install_npm
RUN mkdir -p /opt/open5gs

# Set ownership and permissions of Open5GS directories and files:
RUN chown -R open5gs:open5gs /run/mongodb && \
    chown -R open5gs:open5gs /etc/mongodb.conf && \
    chown -R open5gs:open5gs /opt/open5gs* && \
    chmod +x /opt/start_mongodb.sh && \
    chmod +x /opt/start_app.sh
