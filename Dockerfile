FROM alpine:latest
LABEL org.opencontainers.image.authors="d3fk"
LABEL org.opencontainers.image.source="https://github.com/Angatar/postgresql-s3-backup.git"
LABEL org.opencontainers.image.url="https://github.com/Angatar/postgresql-s3-backup"

RUN apk upgrade --no-cache \
  &&  echo  https://dl-cdn.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories \
  && apk add --no-cache postgresql-client gpg ca-certificates s3cmd
  
WORKDIR /s3
