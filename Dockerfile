FROM centos:7
ENV container docker
MAINTAINER smccloud

# Install updates
RUN yum -y upgrade
RUN apt-get -y dist-upgrade

# Install tools needed to build Transmission
RUN yum -y install gcc gcc-c++ m4 make automake libtool gettext openssl-devel bzip2 libcurl libcurl-devel glib-devel glib2 glib2-devel perl-libxml-perl

# Prepare build environment
RUN mkdir /bld
WORKDIR /bld
RUN curl -o transmission-2.03.tar.bz2 https://raw.githubusercontent.com/transmission/transmission-releases/master/transmission-2.03.tar.bz2
RUN tar xvf transmission-2.03.tar.bz2
RUN curl -o pkg-config-0.29.2.tar.gz https://pkg-config.freedesktop.org/releases/pkg-config-0.29.2.tar.gz
RUN tar xvf pkg-config-0.29.2.tar.gz
RUN curl -o intltool-0.40.6.tar.bz2 http://ftp.gnome.org/pub/gnome/sources/intltool/0.40/intltool-0.40.6.tar.bz2
RUN tar xvf intltool-0.40.6.tar.bz2
RUN curl -o curl-7.64.0.tar.bz2 https://curl.haxx.se/download/curl-7.64.0.tar.bz2
RUN tar xvf curl-7.64.0.tar.bz2
WORKDIR /bld/curl-7.64.0
RUN ./buildconf
RUN ./configure
RUN make
RUN make install
WORKDIR /bld/pkg-config-0.29.2
RUN ./configure
RUN make
RUN make install
WORKDIR /bld/intltool-0.40.6
RUN ./configure
RUN make
RUN make install
WORKDIR /bld/transmission-2.03
RUN ./configure --enable-daemon
RUN make
RUN make install

# Expose WebUI port
EXPOSE 9091

# Expose TCP & UDP ports for torrent data
EXPOSE 51413
EXPOSE 51413/udp

# Map /config to host defined config path (used to store configuration from app)
VOLUME /config

# Map /data to host defined data path (used to store data from app)
VOLUME /data

# Add pre-configured config files for nobody
ADD config/nobody/ /home/nobody/

# Set environment variables for user nobody
ENV HOME /home/nobody

# Run script to set uid, gid and permissions
CMD ["/usr/sbin/init"]
