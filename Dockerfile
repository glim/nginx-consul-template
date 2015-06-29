# nginx web/proxy server with consul-template bundled

FROM ubuntu:trusty
MAINTAINER Jameson Holden <me@jameson.cc>

ENV CONSUL_TEMPLATE_VERSION 0.9.0
ENV CONSUL_TEMPLATE_URL https://github.com/hashicorp/consul-template/releases/download/v${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.tar.gz

# Install curl nginx-extras and consul-template
RUN \
  apt-get update && apt-get upgrade -y --no-install-recommends && \
  apt-get -y install curl nginx && \
  rm -rf /etc/nginx/sites-enabled/* && \
  rm -rf /var/lib/apt/lists/* && \
  curl -L $CONSUL_TEMPLATE_URL | tar -C /usr/local/bin --strip-components 1 -zxf -

# Forward request and error logs to docker log collector
RUN \
  ln -sf /dev/stdout /var/log/nginx/access.log && \
  ln -sf /dev/stderr /var/log/nginx/error.log && \
  ln -sf /dev/stdout /var/log/consul-template.log

ADD start.sh /srv/start.sh
ADD consul-template.cfg /etc/consul-template/config.cfg
ADD templates/ /etc/consul-template/templates/
ADD nginx.conf /etc/nginx/nginx.conf

VOLUME ["/var/cache/nginx"]

EXPOSE 80 443

WORKDIR /srv
ENTRYPOINT ["/srv/start.sh"]
