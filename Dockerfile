# Pull base image.
FROM kdelfour/supervisor-docker
MAINTAINER Richard Yu <vipzhicheng@gmail.com>

# ------------------------------------------------------------------------------
# Change locale
RUN locale-gen en_US.UTF-8 && export LANG=en_US.UTF-8

# ------------------------------------------------------------------------------
# Change apt source list to ali mirror
RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak \
	&& echo ' \n\
deb http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse \n\
deb http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse \n\
deb http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse \n\
deb http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse \n\
deb http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse \n\
deb-src http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse \n\
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse \n\
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse \n\
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse \n\
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse \n\
' > /etc/apt/sources.list

# ------------------------------------------------------------------------------
# Install common packages
RUN apt-get update \
	&& apt-get install -y --force-yes vim htop sqlite3 \
	&& apt-get install -y build-essential g++ curl libssl-dev apache2-utils git libxml2-dev sshfs

# ------------------------------------------------------------------------------
# Install PHP related
RUN apt-get install -y software-properties-common python-software-properties \
	&& add-apt-repository ppa:ondrej/php -y \
	&& apt-get update \
	&& apt-get install -y --force-yes php7.1-dev php7.1-cli php7.1-common php7.1-gd php7.1-mbstring php7.1-mysql php7.1-xml php7.1-zip php7.1-opcache php7.1-sqlite3 php-xdebug \
	&& echo ' \n\
	xdebug.remote_enable=1 \n\
	' >> /etc/php/7.1/cli/conf.d/20-xdebug.ini

# ------------------------------------------------------------------------------
# Install Composer & Laravel Installer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
	&& php -r "if (hash_file('SHA384', 'composer-setup.php') === '669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
	&& php composer-setup.php \
	&& php -r "unlink('composer-setup.php');" \
	&& mv composer.phar /usr/local/bin/composer \
	&& composer config -g repo.packagist composer https://packagist.phpcomposer.com \
	&& echo "PATH=$PATH:$HOME/.composer/vendor/bin" >> ~/.bash_profile

# ------------------------------------------------------------------------------
# Install Laravel Installer
RUN composer global require "laravel/installer"

# ------------------------------------------------------------------------------
# Install Drupal Drush
RUN php -r "readfile('https://s3.amazonaws.com/files.drush.org/drush.phar');" > drush.phar \
	&& php drush.phar core-status \
	&& chmod +x drush.phar \
	&& sudo mv drush.phar /usr/local/bin \
	&& ln -s /usr/local/bin/drush.phar /usr/local/bin/drush \
    && drush init -y

# ------------------------------------------------------------------------------
# Install Drupal Console
RUN php -r "readfile('https://drupalconsole.com/installer');" > drupal.phar \
	&& mv drupal.phar /usr/local/bin \
	&& chmod +x /usr/local/bin/drupal.phar \
	&& ln -s /usr/local/bin/drupal.phar /usr/local/bin/drupal


# ------------------------------------------------------------------------------
# Install Cloud9
RUN curl -sL https://deb.nodesource.com/setup | bash -
RUN apt-get install -y nodejs

RUN git clone https://github.com/c9/core.git /cloud9
WORKDIR /cloud9
RUN scripts/install-sdk.sh

# Tweak standlone.js conf
RUN sed -i -e 's_127.0.0.1_0.0.0.0_g' /cloud9/configs/standalone.js 

# Add supervisord conf
ADD conf/cloud9.conf /etc/supervisor/conf.d/

# ------------------------------------------------------------------------------
# Add volumes
RUN mkdir /workspace
VOLUME /workspace

# ------------------------------------------------------------------------------
# Install nvm node nrm
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.1/install.sh | bash \
	&& export NVM_DIR="$HOME/.nvm" \
	&& [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" \
	&& nvm install node \
	&& nvm use node \

	&& npm install -g nrm --registry=https://registry.npm.taobao.org \
	&& nrm use taobao \

	&& npm install -g vue-cli babel-cli hexo-cli

# ------------------------------------------------------------------------------
# .bashrc not loaded by container
RUN echo 'source ~/.bashrc' >> ~/.bash_profile

# ------------------------------------------------------------------------------
# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ------------------------------------------------------------------------------
# Expose ports.
EXPOSE 80
EXPOSE 3000
EXPOSE 8000
EXPOSE 8080

# ------------------------------------------------------------------------------
# Start supervisor, define default command.
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]