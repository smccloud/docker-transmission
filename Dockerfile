FROM ubuntu:12.04
ENV container docker
MAINTAINER smccloud

# Install updates
RUN apt-get update && apt-get dist-upgrade -y

# Install tools needed to build Transmission
RUN apt-get install build-essential wget automake autoconf libtool pkg-config intltool libcurl4-openssl-dev libglib2.0-dev libevent-dev libminiupnpc-dev libgtk-3-dev libappindicator3-dev -y

# Prepare build environment
RUN mkdir /bld
WORKDIR /bld
RUN wget --no-check-certificate https://raw.githubusercontent.com/transmission/transmission-releases/master/transmission-2.03.tar.bz2
RUN tar xvf transmission-2.03.tar.bz2
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
RUN mkdir /config
VOLUME /config

# Map /data to host defined data path (used to store data from app)
RUN mkdir /data
VOLUME /data

# Add pre-configured config files for nobody
ADD config/nobody/ /home/nobody/

# Set environment variables for user nobody
ENV HOME /home/nobody

# Run script to set uid, gid and permissions
CMD ["/usr/sbin/init"]
