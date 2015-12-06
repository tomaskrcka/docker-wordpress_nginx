FROM wordpress:fpm
MAINTAINER Tomas Krcka <tomas.krcka@nkgroup.cz>

RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62
RUN echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list

ENV NGINX_VERSION 1.9.7-1~jessie

RUN apt-get update && \
    apt-get install -y ca-certificates nginx=${NGINX_VERSION}

RUN apt-get install -y supervisor
RUN mkdir -p /var/log/supervisor

RUN  apt-get -y install php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-pspell php5-recode php5-sqlite php5-tidy php5-xmlrpc php5-xsl && \
     rm -rf /var/lib/apt/lists/*

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ADD ./nginx-site.conf /etc/nginx/conf.d/default.conf

VOLUME ["/var/cache/nginx"]

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord"]

