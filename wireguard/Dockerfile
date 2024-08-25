FROM debian:latest

RUN apt-get update && \
    apt-get install -y wireguard-tools iptables procps iproute2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/wireguard /var/log/wireguard

ENV SERVER_PORT=51820 \
    SERVER_IP=0.0.0.0

EXPOSE 51820/udp

VOLUME /etc/wireguard

COPY server.sh /usr/local/bin/server.sh

RUN chmod +x /usr/local/bin/server.sh

ENTRYPOINT ["/usr/local/bin/server.sh"]

