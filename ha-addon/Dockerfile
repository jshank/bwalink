ARG BUILD_FROM
FROM $BUILD_FROM

RUN apk update
RUN apk --no-cache add bash curl curl-dev ruby-dev build-base
RUN apk --no-cache add ruby ruby-io-console ruby-irb \
  ruby-json ruby-etc ruby-bigdecimal ruby-rdoc \
  libffi-dev zlib-dev ruby-bundler
RUN bundle config set deployment 'true'
RUN gem install balboa_worldwide_app
RUN apk add --no-cache socat tzdata
RUN apk del build-base
RUN rm -rf /var/cache/apk/*

ADD docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

CMD [ "/docker-entrypoint.sh" ]
