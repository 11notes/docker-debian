![banner](https://github.com/11notes/defaults/blob/main/static/img/banner.png?raw=true)

# DEBIAN
![size](https://img.shields.io/docker/image-size/11notes/debian/13?color=0eb305)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![version](https://img.shields.io/docker/v/11notes/debian/13?color=eb7a09)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![pulls](https://img.shields.io/docker/pulls/11notes/debian?color=2b75d6)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)[<img src="https://img.shields.io/github/issues/11notes/docker-DEBIAN?color=7842f5">](https://github.com/11notes/docker-DEBIAN/issues)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![swiss_made](https://img.shields.io/badge/Swiss_Made-FFFFFF?labelColor=FF0000&logo=data:image/svg%2bxml;base64,PHN2ZyB2ZXJzaW9uPSIxIiB3aWR0aD0iNTEyIiBoZWlnaHQ9IjUxMiIgdmlld0JveD0iMCAwIDMyIDMyIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgogIDxyZWN0IHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiIgZmlsbD0idHJhbnNwYXJlbnQiLz4KICA8cGF0aCBkPSJtMTMgNmg2djdoN3Y2aC03djdoLTZ2LTdoLTd2LTZoN3oiIGZpbGw9IiNmZmYiLz4KPC9zdmc+)

Debian base image

# INTRODUCTION 📢

Debian is a complete Free Operating System!

# SYNOPSIS 📖
**What can I do with this?** This image will give you a base Debian image with some additional tweaks like some bin’s (curl, tini) which are present by default and it will not cache any packages. It will also execute the script ```/usr/local/bin/entrypoint.sh``` via [tini](https://github.com/krallin/tini).

If used as a base image for your own image simply leave out your own **ENTRYPOINT** to use the default one and provide your own ```/usr/local/bin/entrypoint.sh```.

# COMPOSE ✂️
```yaml
name: "debian"
services:
  debian:
    image: "11notes/debian:13"
    environment:
      TZ: "Europe/Zurich"
    restart: "always"
```

# BUILD 🚧
```yaml
FROM 11notes/debian:stable
# switch to root during setup
USER root
# setup your app
RUN set -ex; \
  setup your app
# add custom entrypoint to image
COPY ./entrypoint.sh /usr/local/bin
```

# DEFAULT SETTINGS 🗃️
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user name |
| `uid` | 1000 | [user identifier](https://en.wikipedia.org/wiki/User_identifier) |
| `gid` | 1000 | [group identifier](https://en.wikipedia.org/wiki/Group_identifier) |
| `home` | / | home directory of user docker |

# ENVIRONMENT 📝
| Parameter | Value | Default |
| --- | --- | --- |
| `TZ` | [Time Zone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) | |
| `DEBUG` | Will activate debug option for container image and app (if available) | |

# MAIN TAGS 🏷️
These are the main tags for the image. There is also a tag for each commit and its shorthand sha256 value.

* [13](https://hub.docker.com/r/11notes/debian/tags?name=13)
* [stable](https://hub.docker.com/r/11notes/debian/tags?name=stable)

# REGISTRIES ☁️
```
docker pull 11notes/debian:13
docker pull ghcr.io/11notes/debian:13
docker pull quay.io/11notes/debian:13
```

# SOURCE 💾
* [11notes/debian](https://github.com/11notes/docker-DEBIAN)

# PARENT IMAGE 🏛️
> [!IMPORTANT]
>This image is not based on another image but uses [scratch](https://hub.docker.com/_/scratch) as the starting layer.
>The image consists of the following distroless layers that were added:
>* [11notes/distroless](https://github.com/11notes/docker-distroless/blob/master/arch.dockerfile) - contains users, timezones and Root CA certificates
>* [11notes/distroless:curl](https://github.com/11notes/docker-distroless/blob/master/curl.dockerfile) - app to execute HTTP requests
>* 11notes/distroless:tini

# BUILT WITH 🧰
* [debian](https://debianlinux.org)

# GENERAL TIPS 📌
> [!TIP]
>* Use a reverse proxy like Traefik, Nginx, HAproxy to terminate TLS and to protect your endpoints
>* Use Let’s Encrypt DNS-01 challenge to obtain valid SSL certificates for your services

# ElevenNotes™️
This image is provided to you at your own risk. Always make backups before updating an image to a different version. Check the [releases](https://github.com/11notes/docker-debian/releases) for breaking changes. If you have any problems with using this image simply raise an [issue](https://github.com/11notes/docker-debian/issues), thanks. If you have a question or inputs please create a new [discussion](https://github.com/11notes/docker-debian/discussions) instead of an issue. You can find all my other repositories on [github](https://github.com/11notes?tab=repositories).

*created 13.08.2025, 16:04:26 (CET)*