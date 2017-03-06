# Pull base image.
FROM kdelfour/cloud9-docker
MAINTAINER Richard Yu <vipzhicheng@gmail.com>

RUN locale-gen en_US.UTF-8 && export LANG=en_US.UTF-8

# ------------------------------------------------------------------------------
# Install packages
RUN apt-get update \
	&& apt-get install -y software-properties-common python-software-properties \
	&& add-apt-repository ppa:ondrej/php -y
RUN apt-get update \
	&& apt-get install -y --force-yes vim htop \
	&& apt-get install -y --force-yes php7.1-dev php7.1-cli php7.1-common php7.1-gd php7.1-mbstring php7.1-mysql php7.1-xml php7.1-zip php7.1-opcache

# Install Composer & Drupal Console & Drush & Laravel Installer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
	&& php -r "if (hash_file('SHA384', 'composer-setup.php') === '55d6ead61b29c7bdee5cccfb50076874187bd9f21f65d8991d46ec5cc90518f447387fb9f76ebae1fbbacf329e583e30') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
	&& php composer-setup.php \
	&& php -r "unlink('composer-setup.php');" \
	&& mv composer.phar /usr/local/bin/composer

RUN php -r "readfile('https://s3.amazonaws.com/files.drush.org/drush.phar');" > drush.phar \
	&& php drush.phar core-status \
	&& chmod +x drush.phar \
	&& sudo mv drush.phar /usr/local/bin \
	&& ln -s /usr/local/bin/drush.phar /usr/local/bin/drush \
    && drush init -y \

RUN php -r "readfile('https://drupalconsole.com/installer');" > drupal.phar \
	&& mv drupal.phar /usr/local/bin/drupal \
	&& chmod +x /usr/local/bin/drupal

RUN composer global require "laravel/installer" \
	&& echo "PATH=$PATH:$HOME/.composer/vendor/bin" >> ~/.bash_profile

# Install node nrm
RUN npm install -g nrm --registry=https://registry.npm.taobao.org \
	&& nrm use taobao


# ------------------------------------------------------------------------------
# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ------------------------------------------------------------------------------
# Expose ports.
EXPOSE 80
EXPOSE 3000
EXPOSE 8000

# ------------------------------------------------------------------------------
# Start supervisor, define default command.
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]