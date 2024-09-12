# syntax=docker/dockerfile:1
#
ARG IMAGEBASE=frommakefile
#
FROM ${IMAGEBASE}
#
ENV NFSMODE=SERVER \
    LOCKD_PORT=32768 \
    MOUNTD_PORT=32767 \
    STATD_PORT=32765 \
    STATD_OUTGOING_PORT=32766
# these ports are needed in addition to 111 and 2049, requires firewall whitelisted
#
RUN set -xe \
    && apk add --no-cache --purge -uU \
        libnfs \
        nfs-utils \
    && mkdir -p /defaults \
    && mv /etc/exports /defaults/exports.default \
    && rm -f /sbin/halt /sbin/poweroff /sbin/reboot \
    && mkdir -p /var/lib/nfs/rpc_pipefs \
    && mkdir -p /var/lib/nfs/v4recovery \
    && echo "rpc_pipefs /var/lib/nfs/rpc_pipefs rpc_pipefs defaults 0 0" >> /etc/fstab \
    && echo "nfsd       /proc/fs/nfsd           nfsd       defaults 0 0" >> /etc/fstab \
    && rm -rf /var/cache/apk/* /tmp/*
#
COPY root/ /
#
VOLUME /data/
#
EXPOSE 111/udp 111/tcp 2049/udp 2049/tcp 32765/tcp 32765/udp 32766/tcp 32766/udp 32767/tcp 32767/udp 32768/tcp 32768/udp
#
# HEALTHCHECK \
#     --interval=2m \
#     --retries=5 \
#     --start-period=5m \
#     --timeout=10s \
#     CMD \
#     bash -ec "${HEALTHCHECK_CMD:- nfsstat -s}" || exit 1
#
ENTRYPOINT ["/init"]
