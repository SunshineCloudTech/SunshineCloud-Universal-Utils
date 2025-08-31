ARG VARIANT="bookworm"
FROM buildpack-deps:${VARIANT}-curl
USER matrix0523
LABEL maintainer="SunshineCloud"
LABEL description="Dockerfile for building xrdp with pulseaudio support"
# Install packages
ADD sources/sources-bookworm.list /etc/apt/sources.list
ENV DEBIAN_FRONTEND=noninteractive
# RUN sudo sed -i "s/# deb-src/deb-src/g" /etc/apt/sources.list
RUN sudo apt-get -y update
RUN sudo apt-get -y upgrade
ENV BUILD_DEPS="git autoconf pkg-config libssl-dev libpam0g-dev \
    libx11-dev libxfixes-dev libxrandr-dev nasm xsltproc flex \
    bison libxml2-dev dpkg-dev libcap-dev"
RUN sudo apt-get -y install  sudo apt-utils software-properties-common $BUILD_DEPS
# Build xrdp and dependencies
WORKDIR /tmp
RUN sudo apt-get source pulseaudio
RUN sudo apt-get build-dep -yy pulseaudio
RUN sudo tar -xvf pulseaudio_*.orig.tar.xz -C /tmp/
RUN sudo tar -xvf pulseaudio_*.debian.tar.xz
RUN sudo mv debian/ /tmp/pulseaudio-16.1/
WORKDIR /tmp/pulseaudio-16.1
RUN sudo dpkg-buildpackage -rfakeroot -uc -b
WORKDIR /tmp
RUN sudo git clone --branch v0.9.21 --recursive https://github.com/neutrinolabs/xrdp.git
WORKDIR /tmp/xrdp
RUN sudo ./bootstrap
RUN sudo ./configure
RUN sudo make
RUN sudo make install
WORKDIR /tmp
RUN sudo apt install -y libpulse-dev
RUN sudo git clone --recursive https://github.com/neutrinolabs/pulseaudio-module-xrdp.git
WORKDIR /tmp/pulseaudio-module-xrdp
RUN sudo ./bootstrap && sudo ./configure PULSE_DIR=/tmp/pulseaudio-16.1
RUN sudo make
RUN sudo mkdir -p /tmp/so
RUN sudo cp src/.libs/*.so /tmp/so
