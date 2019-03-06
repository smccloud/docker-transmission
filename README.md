## Usage

Here are some example snippets to help you get started creating a container.

### docker

```
docker create \
  --name=transmission \
  -e PUID=1001 \
  -e PGID=1001 \
  -e TZ=Europe/London \
  -e TRANSMISSION_WEB_HOME=/combustion-release/ `#optional` \
  -p 9091:9091 \
  -p 51413:51413 \
  -p 51413:51413/udp \
  -v <path to data>:/config \
  -v <path to downloads>:/downloads \
  -v <path to watch folder>:/watch \
  --restart unless-stopped \
  smccloud/docker-transmission