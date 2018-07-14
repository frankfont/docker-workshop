FROM local/myubuntu18-box
LABEL author_name="Frank Font"
LABEL author_website="https://room4me.com"
LABEL environment_context="DEV"

#Install our custom scripts folder
ADD ./mybucket /var/mybucket

#Refresh apt references
ARG APT_GET_FORCED_DATE=20180702
RUN apt-get update

#Install APACHE2
RUN apt-get install -y apache2
RUN a2enmod rewrite

#Create a webadmin user
ARG THEPASWORD=devexample
RUN useradd -u 1500 -ms /bin/bash webadmin
RUN usermod -aG sudo,www-data webadmin
RUN echo "webadmin:${THEPASWORD}" | chpasswd

#Initialize our default website
ADD ./defaultwebsite /var/www/html
WORKDIR /var/www/html
RUN chown -R webadmin:www-data .

ENV DOCKERFILE_MACHINEBUILD_VERSION "${APT_GET_FORCED_DATE}.1"

#Expose relevant ports
EXPOSE 80

#Set the default user and folder for logins
USER webadmin
WORKDIR /var/www/html

#Declare the default startup command
CMD /var/mybucket/startup.sh INIT




