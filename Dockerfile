FROM ruby:3.1.2-alpine as builder

COPY . /usr/src

RUN apk add --no-cache --update --virtual .build-deps build-base ruby-dev \
    && cd /usr/src \
    && gem build fluent-plugin-shodan.gemspec

FROM fluentd

USER root

COPY --from=builder /usr/src/fluent-plugin-shodan-*.gem /tmp/fluent-plugin-shodan.gem

RUN apk add --no-cache --update --virtual .build-deps build-base ruby-dev \
    && gem install /tmp/fluent-plugin-shodan.gem \
    && gem sources --clear-all \
    && apk del .build-deps \
    && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

USER fluent