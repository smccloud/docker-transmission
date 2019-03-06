FROM ubuntu:18.04
ENV container docker
MAINTAINER smccloud

# Parts of this Docker file and scripts were used from binhex/arch-deluge in order to get Deluge 1.3.11 for IP Torrents

# Install updates
RUN apt-get update
RUN apt-get -y dist-upgrade

# Install tools needed to build Transmission
RUN apt-get -y install build-essential automake autoconf libtool pkg-config intltool libcurl4-openssl-dev libglib2.0-dev libevent-dev libminiupnpc-dev libgtk-3-dev libappindicator3-dev wget libssl-dev openssl

# Prepare build environment
RUN mkdir /bld
RUN wget -O /bld/transmission-2.03.tar.bz2 https://raw.githubusercontent.com/transmission/transmission-releases/master/transmission-2.03.tar.bz2
RUN tar xvf /bld/transmission-2.03.tar.bz2 -C /bld
WORKDIR /bld/transmission-2.03
RUN ./autogen.sh
RUN make -s
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