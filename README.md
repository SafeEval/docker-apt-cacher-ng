# docker-apt-cacher-ng

This is a Docker image and Compose file for creating a network caching proxy
for APT packages. It has been tested on Ubuntu and Debian.

## Service Usage

### Build

The image is simple. Only port 3142/tcp is exposed.

```
docker build -t apt-cacher-ng .
```

### Run

The stack comes with a simple Compose file. 
Named volumes for cache and log data will automatically be created if they
don't exist, and reused if they do. All that is really needed is:

```
docker-compose up
```

If you don't wish to (or can't) use Docker Compose, here is the run instruction:

```
docker run -d -p 3142:3142 \
  --mount source=apt-cacher-cache,target=/var/cache/apt-cacher-ng \
  --mount source=apt-cacher-log,target=/var/log/apt-cacher-ng \
  --restart always \
  --name apt-cacher-ng apt-cacher-ng
```

## Client Proxy Configuration

### Debian and Ubuntu

To make a Debian or Ubuntu host use the caching proxy,
add this APT configuration file.

```
# /etc/apt/apt.conf.d/00proxy

Acquire {
  Retries "0";
  HTTP { Proxy "http://mycacheproxy:3142"; };
};
```

Then run `apt-update`.


### Docker Image (Build-Time)

To use the proxy within Docker image construction, specify a proxy variable
in your compose file, and then make `.env` file that defines the proxy URL.

Compose:

```
# docker-compose.yaml
services:                                                                                
  my-service:                 
    build:         
      context: .
      args:            
        http_proxy: "${http_proxy}"
```

Env

```
# .env
http_proxy=http://mycacheproxy:3142
```


### Docker Container (Run-Time)

To use your APT proxy from within a running container, define the `http_proxy`
environment variable with the proxy URL. For instance, using a Compose file:

```
# docker-compose.yaml
services:                                                                                
  my-service:                 
...
    environment:
      - http_proxy="${http_proxy}"
```

The `.env` file would contain the actual proxy URL in this case, but it can
also be defined directly in the Compose file.

```
# .env
http_proxy=http://mycacheproxy:3142
```


## HTTPS Repositories

### Client Configuration

The way that `apt-cacher-ng` handles HTTPS repositories is not by breaking TLS,
but rather by having clients request HTTP URLs, which get remapped to HTTPS at
the proxy.

```
[Client] --HTTP--> [Proxy] --HTTPS--> [Repository]
```

The only thing a client needs to do is use a HTTP link in their APT source,
instead of HTTPS, so...

```
# /etc/apt/sources.list.d/docker.list
deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable
```
... becomes...

```
# /etc/apt/sources.list.d/docker.list
deb [arch=amd64] http://download.docker.com/linux/ubuntu bionic stable
```

### Server Configuration

Most HTTPS APT repositories seem to have HTTP alternatives (as of this
writing). If you choose to use HTTPS repositories, the server needs to have
a mapping in it's configuration file, `/etc/apt-cacher-ng/acng.conf`.

Just a single line with the HTTPS domain is enough:

```
# /etc/apt-cacher-ng/acng.conf
Remap-docker:    http://download.docker.com ; https://download.docker.com
```

## Volumes

There are two named volumes automatically created, one for the package cache,
and one for service logs. The automatic naming convention results in these
names:

- docker-apt-cacher-ng_cache
- docker-apt-cacher-ng_log

Verify these were created at runtime with:

```
docker volume ls
```
