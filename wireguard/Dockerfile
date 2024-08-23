FROM debian:latest

RUN apt-get update && \
    apt-get install -y wireguard-tools iproute2 qrencode && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/wireguard /var/log/wireguard

ENV SERVER_PORT=51820/udp \
    SERVER_IP=0.0.0.0

EXPOSE 51280

VOLUME /etc/wireguard

COPY server.sh /usr/local/bin/server.sh

RUN chmod +x /usr/local/bin/server.sh

ENTRYPOINT ["/usr/local/bin/server.sh"]


