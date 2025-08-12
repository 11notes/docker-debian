# ╔═════════════════════════════════════════════════════╗
# ║                       SETUP                         ║
# ╚═════════════════════════════════════════════════════╝
# GLOBAL
  ARG APP_UID=1000 \
      APP_GID=1000 \
      APP_VERSION=13

# :: FOREIGN IMAGES
  FROM 11notes/util AS util

    
# ╔═════════════════════════════════════════════════════╗
# ║                       IMAGE                         ║
# ╚═════════════════════════════════════════════════════╝
# :: HEADER
  FROM debian:trixie-slim

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
    COPY --from=util / /
    COPY ./rootfs /

# :: INSTALL
  RUN set -ex; \
    apt update -y; \
    apt upgrade -y; \
    apt install -y \
      adduser \
      curl \
      tini; \
    addgroup --gid ${APP_GID} docker; \
    adduser --uid ${APP_UID} --ingroup docker --shell /sbin/nologin --home / --disabled-password --disabled-login --quiet --gecos "" docker; \
    chmod +x -R /usr/local/bin;

# :: EXECUTE
  USER ${APP_UID}:${APP_GID}
  ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]