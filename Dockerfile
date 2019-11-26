FROM cloudposse/apache-streaming

LABEL maintainer "Markku Virtanen"

ENV APACHE_MOD_H264_VERSION 2.2.7

ADD http://h264.code-shop.com/download/apache_mod_h264_streaming-${APACHE_MOD_H264_VERSION}.tar.gz /usr/src/apache_mod_h264_streaming.tar.gz
ADD http://people.apache.org/~pquerna/modules/mod_flvx.c /usr/src/mod_flvx.c

RUN apt-get update && \
    apt-get -y install apache2-dev build-essential && \
    tar -zvxf /usr/src/apache_mod_h264_streaming.tar.gz -C /usr/src/ &&  \
    cd /usr/src/mod_h264_streaming-${APACHE_MOD_H264_VERSION}/ && \
    ./configure --with-apxs=`which apxs` && \
    make && \
    make install && \
    apxs2 -c -i /usr/src/mod_flvx.c && \
    chmod 644 /usr/lib/apache2/modules/mod_flvx.so && \
    apt-get -y remove build-essential && \
    dpkg --get-selections | awk '{print $1}'|cut -d: -f1|grep -- '-dev$' | xargs apt-get remove -y && \
    rm -rf /usr/src && \
    apt-get clean all && \
    rm -rf /tmp/*

# Link access log to stdout
RUN ln -sf /dev/stdout /var/log/apache2/access.log

ADD mods-available/ /etc/apache2/mods-available/

RUN a2enmod h264_streaming && \
    a2enmod flvx && \
    a2dismod cgi && \
    a2disconf db-env && \
    echo "RemoteIPHeader X-Forwarded-For" >> /etc/apache2/apache2.conf && \
    echo "RemoteIPTrustedProxy 10.0.0.0/8" >> /etc/apache2/apache2.conf && \
    sed -i.bak 's/LogFormat "%h %l %u %t \\"%r\\" %>s %O \\"%{Referer}i\\" \\"%{User-Agent}i\\"" combined/LogFormat "%a %l %u %t \\"%r\\" %>s %O \\"%{Referer}i\\" \\"%{User-Agent}i\\"" combined/' /etc/apache2/apache2.conf
