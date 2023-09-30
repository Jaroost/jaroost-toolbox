FROM postgres:latest

COPY ./docker/postgres/initdb /docker-entrypoint-initdb.d