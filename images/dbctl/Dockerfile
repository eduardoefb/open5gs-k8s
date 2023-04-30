FROM debian:11
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python3 python3-pymongo python3-yaml

# Change UID and GID of Open5GS user:   
RUN useradd open5gs 
RUN groupmod open5gs -g 1024 && \
    usermod open5gs -u 1024 -G open5gs && \
    mkdir /home/open5gs && \
    cd /home/open5gs && \    
    usermod open5gs -d /home/open5gs/

COPY subscriber.py /home/open5gs/subscriber.py
RUN chown -R open5gs:open5gs /home/open5gs/ && \
    chmod +x /home/open5gs/subscriber.py
