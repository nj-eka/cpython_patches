# https://github.com/bdellegrazie/docker-ubuntu-systemd/blob/master/Dockerfile
FROM ubuntu:20.10
LABEL maintainer="njeka0108@gmail.com"
ENV container=docker
ENV TZ=Europe/Moscow
WORKDIR /opt/cpy395
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    sed -i 's/# deb/deb/g' /etc/apt/sources.list && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -qq && \
    apt-get install -yq apt-utils && \ 
    apt-get build-dep python3.9 -yq && \
    apt-get install -yq git && \
    apt-get clean && \
    rm -rf /usr/share/doc/* /usr/share/man/* /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN cd /opt/ && git clone --branch v3.9.5 --single-branch --depth 1 https://github.com/nj-eka/cpython cpy395
RUN cd /opt/cpy395/ && ./configure --with-pydebug

