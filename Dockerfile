FROM ruby:3-alpine
LABEL org.opencontainers.image.source="https://github.com/jshank/bwalink"

# Fix for dev tools from https://renehernandez.io/snippets/install-development-tools-in-alpine/
# This also adds the build-base, uses it and then wipes out the tools to keep the image small
# Installing socat to link the serial over IP device
RUN apk update && apk add --no-cache build-base && \
    bundle config set deployment 'true' && \
    gem install balboa_worldwide_app && \
    apk add --no-cache socat tzdata && \
    apk del build-base && \
    rm -rf /var/cache/apk/*

# See https://iotbyhvm.ooo/using-uris-to-connect-to-a-mqtt-server/ for MQTT_URI format
# BRIDGE_IP and BRIDGE_PORT are the address and port for your serial to IP device or 
# host running ser2net, socat or ESPEasy serial server
ENV MQTT_URI=mqtt://balboa:balboa@10.1.10.2 \
    BRIDGE_IP=10.1.12.127 \
    BRIDGE_PORT=8899

ADD docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]