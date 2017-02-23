FROM ubuntu:trusty-20170119

# Required system packages
RUN apt-get update \
    && apt-get install -y \
        wget \
        unzip \
        build-essential \
        libreadline6-dev \
        ruby-dev \
        libncurses5-dev \
        perl \
        libpcre3-dev \
        libssl-dev \
    && gem install fpm

RUN mkdir -p /build/root
WORKDIR /build

ARG DEB_VERSION
ARG DEB_PACKAGE

# Download packages
RUN wget -O bup-$DEB_VERSION.tar.gz https://github.com/bup/bup/archive/$DEB_VERSION.tar.gz \
    && tar xfz bup-$DEB_VERSION.tar.gz

RUN apt-get install -y python2.7-dev git-core python-pyxattr python-pylibacl linux-libc-dev

# Compile and install
RUN cd /build/bup-$DEB_VERSION \
    && make install DESTDIR=/build/root

# Build deb
RUN fpm -s dir -t deb \
    -n bup \
    -v $DEB_VERSION-$DEB_PACKAGE \
    -C /build/root \
    -p bup_VERSION_ARCH.deb \
    -d 'python2.7' \
    -d 'python-pyxattr' \
    -d 'python-pylibacl' \
    -d 'acl' \
    -d 'attr' \
    --maintainer 'Phillipp Röll <phillipp.roell@trafficplex.de>' \
    --deb-build-depends build-essential \
    usr
