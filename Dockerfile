FROM gsmlg/phoenix:alpine AS builder

ENV MIX_ENV=prod \
    NAME=gsmlg

COPY . /build

RUN apk update \
    && rm -rf /build/assets/node_modules /build/assets/_build /build/assets/deps \
    && cd /build/assets && ./yarn && ./yarn run build \
    && cd /build && mix do deps.get, compile, release \
    && mkdir /app \
    && tar zxvf "/build/_build/prod/rel/${NAME}/releases/$(grep version /build/mix.exs |awk -F'[\"]' '{print $2}')/${NAME}.tar.gz" -C /app \
    && rm -rf /var/cache/apk/*

FROM alpine:3.8

LABEL maintainer="GSMLG < me@gsmlg.org >"

ENV PORT=80 \
    ERL_EPMD_PORT=4369 \
    NAME=gsmlg \
    SERVER_NAME=www.gsmlg.org \
    NODE_NAME=gsmlg_org \
    ERLCOOKIE=erlang_cookie

RUN apk update \
    && apk add openssl \
    && apk add bash \
    && rm -rf /var/cache/apk/*

COPY entrypoint.sh /

COPY --from=builder /app /app

EXPOSE 80 4369

ENTRYPOINT ["/entrypoint.sh"]
