FROM centos:6
ENV container docker
MAINTAINER smccloud

# Install EPEL
RUN yum -y install epel-release

# Install updates
RUN yum -y upgrade

# Install tools needed to build Transmission
RUN yum -y install gcc gcc-c++ m4 make automake libtool gettext openssl-devel bzip2 libcurl libcurl-devel glib-devel glib2 glib2-devel perl-libxml-perl wget

# Prepare build environment
RUN mkdir /bld
WORKDIR /bld
RUN wget https://raw.githubusercontent.com/transmission/transmission-releases/master/transmission-2.03.tar.bz2
RUN tar xvf transmission-2.03.tar.bz2
RUN wget https://pkg-config.freedesktop.org/releases/pkg-config-0.29.2.tar.gz
RUN tar xvf pkg-config-0.29.2.tar.gz
RUN wget http://ftp.gnome.org/pub/gnome/sources/intltool/0.40/intltool-0.40.6.tar.bz2
RUN tar xvf intltool-0.40.6.tar.bz2
RUN wget https://curl.haxx.se/download/curl-7.64.0.tar.bz2
RUN tar xvf curl-7.64.0.tar.bz2
RUN wget https://github.com/libevent/libevent/releases/download/release-2.1.8-stable/libevent-2.1.8-stable.tar.gz
RUN tar xvf libevent-2.1.8-stable.tar.gz
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
WORKDIR /bld/libevent-2.1.8-stable
RUN ./configure
RUN make
RUN make install
WORKDIR /bld/transmission-2.03
RUN ./configure CFLAGS="-I/usr/local/include/event2/" --enable-daemon
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
