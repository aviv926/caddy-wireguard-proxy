FROM caddy:2-builder AS builder

RUN xcaddy build v2.10.2 \
    --with github.com/mholt/caddy-l4

FROM caddy:2

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY Caddyfile /etc/caddy/
