# ╔═════════════════════════════════════════════════════╗
# ║                       SETUP                         ║
# ╚═════════════════════════════════════════════════════╝
# GLOBAL
  ARG APP_UID=1000 \
      APP_GID=1000 \
      APP_VERSION=0

# :: FOREIGN IMAGES
  FROM 11notes/util AS util
  FROM 11notes/distroless AS distroless
  FROM 11notes/distroless:curl AS distroless-curl
  FROM 11notes/distroless:tini AS distroless-tini
  FROM 11notes/distroless:ds AS distroless-ds


# ╔═════════════════════════════════════════════════════╗
# ║                       BUILD                         ║
# ╚═════════════════════════════════════════════════════╝
# :: DEBIAN
  FROM alpine AS source
  COPY --from=util / /
  ARG TARGETARCH \
      TARGETVARIANT \
      APP_VERSION

  RUN set -ex; \
    apk --update --no-cache add \
      pv \
      tar \
      xz \
      wget; \
    DEBIAN_VERSION=$(eleven debian versiontoname ${APP_VERSION}); \
    case "${TARGETARCH}${TARGETVARIANT}" in \
      "amd64") wget -q --show-progress --progress=bar:force https://github.com/debuerreotype/docker-debian-artifacts/raw/refs/heads/dist-amd64/${DEBIAN_VERSION}/slim/oci/blobs/rootfs.tar.gz;; \
      "arm64") wget -q --show-progress --progress=bar:force https://github.com/debuerreotype/docker-debian-artifacts/raw/refs/heads/dist-arm64v8/${DEBIAN_VERSION}/slim/oci/blobs/rootfs.tar.gz;; \
      "armv7") wget -q --show-progress --progress=bar:force https://github.com/debuerreotype/docker-debian-artifacts/raw/refs/heads/dist-arm32v7/${DEBIAN_VERSION}/slim/oci/blobs/rootfs.tar.gz;; \
    esac; \
    mkdir -p /distroless; \
    pv /rootfs.tar.gz | tar xz -C /distroless;


# :: FILE-SYSTEM
  FROM scratch AS build
  COPY --from=source /distroless/ /
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

  COPY --from=util / /
  COPY ./rootfs /
  COPY --from=distroless / /
  COPY --from=distroless-curl / /
  COPY --from=distroless-tini / /
  COPY --from=distroless-ds / /

  RUN set -ex; \
    chmod +x -R /usr/local/bin;

  RUN set -ex; \
    find /bin /sbin /usr/bin /usr/sbin -type f -executable \
      -not -name "apt-key" \
      -not -name "ctrlaltdel" \
      -not -name "wipefs" \
      -not -name "dpkg-maintscript-helper" \
    -exec /usr/local/bin/ds {} ';'; \
    /usr/local/bin/ds --bye;

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