FROM debian:bookworm

RUN apt update -y && apt upgrade -y && apt install -y mariadb-server mariadb-client

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/run-script.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/run-script.sh

ENTRYPOINT ["/usr/local/bin/run-script.sh"]