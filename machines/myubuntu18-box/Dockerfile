FROM ubuntu:18.04
LABEL author_name="Frank Font"
LABEL author_website="https://room4me.com"
LABEL environment_context="DEV"

USER root

#Install our custom scripts folder
ADD ./mybucket /var/mybucket

#Install core utilities
ARG APT_GET_FORCED_DATE=20180701
RUN apt-get update
RUN apt-get install -y apt-utils
RUN apt-get install -y vim
RUN apt-get install -y curl
RUN apt-get install -y git
RUN apt-get install -y rsync
RUN apt-get install -y zip
RUN apt-get install -y sudo

#Install and configure time zone stuff non-interactively
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y tzdata
RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata

ENV DOCKERFILE_MACHINEBUILD_VERSION "${APT_GET_FORCED_DATE}.3"

#Invoke the startup script
CMD /var/mybucket/startup.sh INIT




