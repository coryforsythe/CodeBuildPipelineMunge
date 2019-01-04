FROM ubuntu:16.04

RUN set -ex \
    && echo 'Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/99use-gzip-compression \
    && apt-get update \
    && apt install -y apt-transport-https \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
    && apt-get install -y --no-install-recommends unzip zip wget python=2.7.* python2.7-dev=2.7.* groff-base \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

RUN set -ex \
    && wget "https://bootstrap.pypa.io/2.6/get-pip.py" -O /tmp/get-pip.py \
    && python /tmp/get-pip.py \
    && pip install awscli==1.* \
    && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip install awscli boto3 pyOpenSSL ndg-httpsclient pyasn1 --upgrade

COPY dockerd-entrypoint.sh /usr/local/bin/
COPY getSource /usr/local/bin
