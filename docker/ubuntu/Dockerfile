FROM ubuntu:20.04
RUN apt-get update && apt-get upgrade -y && apt-get install -y sudo openssl ca-certificates
RUN echo "Set disable_coredump false" >> /etc/sudo.conf
RUN groupadd ubuntu && useradd \
    --gid ubuntu \
    --home-dir /home/ubuntu \
    --create-home \
    --shell /usr/bin/bash \
    --comment "Ubuntu Default User" \
    ubuntu && usermod -aG sudo ubuntu && \
    usermod --password $(openssl passwd -1 ubuntu) ubuntu
USER ubuntu
WORKDIR /home/ubuntu
