FROM local/myubuntu18-apache-webserver
LABEL author_name="Frank Font"
LABEL author_website="https://room4me.com"
LABEL environment_context="DEV"

USER root

#Install our custom scripts folder
COPY ./mybucket /var/mybucket

#Refresh apt references
ARG APT_GET_FORCED_DATE=20180713
RUN apt-get update

#Install PHP7
ARG PHPVER=7.2
RUN apt-get install -y php${PHPVER}
RUN apt-get install -y php${PHPVER}-gmp
RUN apt-get install -y php${PHPVER}-curl 
RUN apt-get install -y php${PHPVER}-gd
RUN apt-get install -y php${PHPVER}-mbstring 
RUN apt-get install -y php${PHPVER}-json 
RUN apt-get install -y php${PHPVER}-xml 
RUN apt-get install -y php${PHPVER}-mysql
RUN apt-get install -y php${PHPVER}-opcache
RUN apt-get install -y php${PHPVER}-gmp
RUN apt-get install -y libapache2-mod-php${PHPVER}
RUN apt-get install -y php${PHPVER}-cli 

#Install composer
RUN mkdir /tmp/downloads
WORKDIR /tmp/downloads
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

#Install Node.js and NPM
WORKDIR /tmp/downloads
RUN apt-get install -y software-properties-common
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs

#Initialize our default website
RUN rm -rf /var/www/html
ADD ./defaultwebsite /var/www/html
WORKDIR /var/www/html
RUN chown -R webadmin:www-data .

ENV DOCKERFILE_MACHINEBUILD_VERSION "${APT_GET_FORCED_DATE}.1"






