FROM ubuntu:latest

RUN apt update
RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata
RUN apt-get -y install curl git unzip xz-utils zip libglu1-mesa openjdk-8-jdk wget nginx

RUN useradd -ms /bin/bash developer
USER developer
WORKDIR /home/developer

RUN git clone https://github.com/flutter/flutter.git -b beta
ENV PATH "$PATH:/home/developer/flutter/bin"

RUN flutter config --enable-web && flutter doctor