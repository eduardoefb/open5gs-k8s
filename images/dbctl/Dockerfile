FROM debian:11
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y curl gpg git
RUN curl -fsSL https://pgp.mongodb.com/server-6.0.asc |    gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg    --dearmor && \
    echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg] http://repo.mongodb.org/apt/debian bullseye/mongodb-org/6.0 main" |  tee /etc/apt/sources.list.d/mongodb-org-6.0.list &&\
    apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mongodb-org

# Change UID and GID of Open5GS user:   
RUN useradd open5gs 
RUN groupmod open5gs -g 1024 && \
    usermod open5gs -u 1024 -G open5gs && \
    mkdir /home/open5gs && \
    cd /home/open5gs && \
    git clone https://github.com/open5gs/open5gs.git && \
    usermod open5gs -d /home/open5gs/

COPY subscriber_create.sh /home/open5gs/subscriber_create.sh 
RUN chown -R open5gs:open5gs /home/open5gs/ && \
    chmod +x /home/open5gs/subscriber_create.sh
