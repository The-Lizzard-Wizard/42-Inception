FROM debian:bookworm

RUN apt update -y && apt upgrade -y && \
    apt install -y nginx openssl

COPY conf/nginx.conf /etc/nginx/conf.d/default.conf
COPY tools/run-script.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/run-script.sh

ENTRYPOINT ["/usr/local/bin/run-script.sh"]