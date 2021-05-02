ARG NODE_VERSION=16-buster
FROM node:$NODE_VERSION

# install any security updates
RUN DEBIAN_FRONTEND=noninteractive apt -y update \
    && DEBIAN_FRONTEND=noninteractive apt -y upgrade \
    && apt -y clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /opt/meshcentral

ARG MC_VERSION=latest
RUN npm install meshcentral@$MC_VERSION

COPY config.json.template config.json.template
COPY startup.sh startup.sh

EXPOSE 443
EXPOSE 80  # MC *really* doesn't want you to use this

ENV MC_HOSTNAME
ENV REVERSE_PROXY
ENV REVERSE_PROXY_TLS_PORT
ENV IFRAME
ENV ALLOW_NEW_ACCOUNTS
ENV WEBRTC

VOLUME /opt/meshcentral/meshcentral-data
VOLUME /opt/meshcentral/meshcentral-files

ENTRYPOINT ["/opt/meshcentral/startup.sh"]
