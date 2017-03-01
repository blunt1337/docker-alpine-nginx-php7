# PHP 7 docker environement with alpine, nginx, php7

# Alpine base
FROM alpine:edge
MAINTAINER Olivier Blunt <olivier.blunt@gmail.com>

# Install
COPY install /install
RUN /bin/sh /install/install.sh

# App files
COPY index.php /app/index.php
WORKDIR /app

# Setup
COPY setup /setup
RUN /bin/sh /setup/setup.sh

# Run
EXPOSE 80
CMD ["runsvdir", "/etc/service"]