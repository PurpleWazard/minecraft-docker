FROM debian:latest

RUN apt-get update -y && \
    apt-get install -y curl cron && \
    apt-get clean && \
    rm -rf /var/lib/apt/list/*

COPY server.sh /usr/local/bin/server.sh
RUN chmod +x /user/local/bin/server.sh

ENTRYPOINT ["/usr/local/bin/server.sh"]
