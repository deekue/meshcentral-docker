ARG BITNAMI_NODE_VERSION=16-prod-debian-10
FROM bitnami/node:$BITNAMI_NODE_VERSION

ENV MC_HOSTNAME \
    REVERSE_PROXY=false \
    REVERSE_PROXY_TLS_PORT=443 \
    IFRAME=false \
    ALLOW_NEW_ACCOUNTS=true \
    WEBRTC=false

# install any security updates, add setcap
ARG DEBIAN_FRONTEND=noninteractive
RUN apt -y update \
    && apt -y upgrade \
    && apt -y install libcap2-bin \
    && apt -y clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /opt/meshcentral

ARG MC_VERSION=stable
RUN npm install meshcentral@$MC_VERSION \
    && npm info meshcentral \
    && node node_modules/meshcentral --listuserids
    # run no-op command to finish install

COPY config.json.template config.json.template
COPY startup.sh startup.sh

EXPOSE 443
EXPOSE 4443
EXPOSE 80

VOLUME /opt/meshcentral/meshcentral-data
VOLUME /opt/meshcentral/meshcentral-files

# Create user/group for node to run as instead of root
# Allow node to bind to low ports as non-root
ARG MC_UID=1000
ARG MC_GID=1000
ARG MC_USER=meshcentral
RUN groupadd -fog "$MC_GID" "$MC_USER" \
    && useradd -u "$MC_UID" -g "$MC_GID" -o -c '' "$MC_USER" \
    && /sbin/setcap 'cap_net_bind_service=+ep' `which node`

USER "$MC_USER"
ENTRYPOINT ["/opt/meshcentral/startup.sh"]
