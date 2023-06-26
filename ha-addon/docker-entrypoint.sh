#!/usr/bin/with-contenv bashio

bashio::log.info "Starting BWALink addon..."

BRIDGE_IP=$(bashio::config 'bridge_ip')
BRIDGE_PORT=$(bashio::config 'bridge_port')
export TZ=$(bashio::info.timezone)
export LOG_LEVEL=$(bashio::config 'log_level')

bashio::log.info "Setting addon timezone to ${TZ} based on the system timezone."

if bashio::config.has_value 'mqtt_uri'; then
    MQTT_URI=$(bashio::config 'mqtt_uri')
# no mqtt config is supplied, so let's use the mqtt addon config
elif bashio::var.has_value "$(bashio::services 'mqtt')"; then
    MQTT_USER="$(bashio::services 'mqtt' 'username')"
    MQTT_PASSWORD="$(bashio::services 'mqtt' 'password')"
    if bashio::var.true "$(bashio::services 'mqtt' 'ssl')"; then
        MQTT_URI="mqtts://${MQTT_USER}:${MQTT_PASSWORD}@$(bashio::services 'mqtt' 'host'):$(bashio::services 'mqtt' 'port')"
    else
        MQTT_URI="mqtt://${MQTT_USER}:${MQTT_PASSWORD}@$(bashio::services 'mqtt' 'host'):$(bashio::services 'mqtt' 'port')"
    fi
else
    bashio::log.error "No MQTT configuration found. Exiting..."
    exit 1
fi

DEVICE=/run/service/hottub
if bashio::var.true "$(bashio::config 'socat')"; then
    bashio::log.info "Starting socat connecting ${DEVICE} to ${BRIDGE_IP}:${BRIDGE_PORT}"
    #Start-up socat to bind the remote serial to IP relay to a virtual port on /run/service/hottub
    socat pty,link=${DEVICE},b115200,raw,echo=0 tcp4:${BRIDGE_IP}:${BRIDGE_PORT},forever,interval=10,fork &
else
    DEVICE="tcp://${BRIDGE_IP}:${BRIDGE_PORT}/"
fi

bashio::log.info "Starting mqtt bridge connecting ${DEVICE} to ${MQTT_URI/:*@/://}"

#Launch the bwa_mqtt_bridge 
#/usr/local/bundle/bin/bwa_mqtt_bridge ${MQTT_URI} /dev/hottub
#/usr/local/bundle/bin/bwa_mqtt_bridge ${MQTT_URI} /dev/hottub

exec /usr/bin/bwa_mqtt_bridge ${MQTT_URI} ${DEVICE}
