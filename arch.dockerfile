# ╔═════════════════════════════════════════════════════╗
# ║                       SETUP                         ║
# ╚═════════════════════════════════════════════════════╝
# GLOBAL
  ARG APP_UID=1000 \
      APP_GID=1000 \
      APP_VERSION=0

# :: FOREIGN IMAGES
  FROM 11notes/util AS util
  FROM 11notes/distroless:curl AS distroless-curl
  FROM 11notes/distroless:tini AS distroless-tini
  FROM 11notes/distroless:ds AS distroless-ds


# ╔═════════════════════════════════════════════════════╗
# ║                       BUILD                         ║
# ╚═════════════════════════════════════════════════════╝
# :: CERTIFICATES
  FROM debian:${APP_VERSION}-slim AS ca-certificates
  ENV DEBIAN_FRONTEND=noninteractive

  RUN set -ex; \
    apt update -y; \
    apt install -y \
      ca-certificates; \
    mkdir -p /distroless/usr/share/ca-certificates; \
    mkdir -p /distroless/etc/ssl/certs; \
    cp -R /usr/share/ca-certificates/* /distroless/usr/share/ca-certificates; \
    cp -R /etc/ssl/certs/* /distroless/etc/ssl/certs;

# :: DEBIAN
  FROM debian:${APP_VERSION}-slim AS build
  COPY --from=ca-certificates /distroless/ /
  COPY --from=distroless-ds / /
  ENV DEBIAN_FRONTEND=noninteractive

  RUN set -ex; \
    find /bin /sbin /usr/bin /usr/sbin -type f -executable \
      -not -name "apt-key" \
      -not -name "ctrlaltdel" \
      -not -name "wipefs" \
      -not -name "dpkg-maintscript-helper" \
      -not -name "deb-systemd-helper" \
      -not -name "update-rc.d" \
      -not -name "invoke-rc.d" \
    -exec /usr/local/bin/ds {} ';'; \
    /usr/local/bin/ds --bye;

  COPY --from=distroless-curl /usr/local/bin/ /usr/local/bin
  COPY --from=distroless-tini / /
  COPY --from=util / /
  COPY ./rootfs /

  RUN set -ex; \
    echo "docker:x:1000:1000:docker:/:/sbin/nologin" >> /etc/passwd; \
    echo "docker:x:1000:docker" >> /etc/group;

  RUN set -ex; \
    chmod +x -R /usr/local/bin;

  RUN set -ex; \
    for FOLDER in /tmp/* /root/*; do \
      rm -rf ${FOLDER}; \
    done;



# ╔═════════════════════════════════════════════════════╗
# ║                       IMAGE                         ║
# ╚═════════════════════════════════════════════════════╝
# :: HEADER
  FROM scratch

  # :: default arguments
    ARG TARGETPLATFORM \
        TARGETOS \
        TARGETARCH \
        TARGETVARIANT \
        APP_IMAGE \
        APP_NAME \
        APP_VERSION \
        APP_ROOT \
        APP_UID \
        APP_GID \
        APP_NO_CACHE

  # :: default environment
    ENV APP_IMAGE=${APP_IMAGE} \
        APP_NAME=${APP_NAME} \
        APP_VERSION=${APP_VERSION} \
        APP_ROOT=${APP_ROOT}

  # :: app specific environment
    ENV DEBIAN_FRONTEND=noninteractive

  # :: multi-stage
    COPY --from=build / /

# :: EXECUTE
  USER ${APP_UID}:${APP_GID}
  ENTRYPOINT ["/usr/local/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]