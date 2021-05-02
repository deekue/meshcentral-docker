#!/bin/bash

MC_CFG=meshcentral-data/config.json
export NODE_ENV=production

export MC_HOSTNAME
export REVERSE_PROXY
export REVERSE_PROXY_TLS_PORT
export IFRAME
export ALLOW_NEW_ACCOUNTS
export WEBRTC

if [[ ! -f "$MC_CFG" ]]
    then
        sed -e "s/\"cert\": \"myserver.mydomain.com\"/\"cert\": \"$MC_HOSTNAME\"/; \
                s/\"NewAccounts\": true/\"NewAccounts\": \"$ALLOW_NEW_ACCOUNTS\"/; \
                s/\"WebRTC\": false/\"WebRTC\": \"$WEBRTC\"/; \
                s/\"AllowFraming\": false/\"AllowFraming\": \"$IFRAME\"/" \
	    < config.json.template \
	    > $MC_CFG
        if [[ "$REVERSE_PROXY" != "false" ]]
            then 
                sed -i "s/\"_certUrl\": \"my\.reverse\.proxy\"/\"certUrl\": \"https:\/\/$REVERSE_PROXY:$REVERSE_PROXY_TLS_PORT\"/" $MC_CFG
		unset MC_HOSTNAME
        fi
else
    # use hostname in config.json
    unset MC_HOSTNAME
fi

exec node node_modules/meshcentral ${MC_HOSTNAME:+--cert "$MC_HOSTNAME"} "$@"
