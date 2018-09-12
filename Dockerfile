# Portable Dockerfile for apt-cacher-ng. Just expose 3142/tcp.
# If the cache or log mount points aren't specified during runtime, the 
# data will be blown away when the container is removed (anonymous volumes).

# Build:   docker build -t apt-cacher-ng .
#
# Run:     docker run -d -p 3142:3142 \
#            --mount source=apt-cacher-cache,target=/var/cache/apt-cacher-ng \
#            --mount source=apt-cacher-log,target=/var/log/apt-cacher-ng \
#            --restart always \
#            --name apt-cacher-ng apt-cacher-ng
#
# Compose: docker-compose up

MAINTAINER Jack Sullivan

FROM    ubuntu:latest

RUN     apt-get update
RUN     apt-get install -y apt-cacher-ng ca-certificates
RUN     chown -R apt-cacher-ng:apt-cacher-ng /var/log/apt-cacher-ng

COPY    ./etc /etc/apt-cacher-ng
VOLUME  /var/cache/apt-cacher-ng
VOLUME  /var/log/apt-cacher-ng

EXPOSE  3142

CMD     chmod 777 /etc/apt-cacher-ng /var/log/apt-cacher-ng /var/cache/apt-cacher-ng && /etc/init.d/apt-cacher-ng start && tail -f /var/log/apt-cacher-ng/*
