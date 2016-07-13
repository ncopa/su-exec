FROM alpine:3.4

RUN apk add --no-cache gcc make musl-dev

VOLUME /mnt
WORKDIR /mnt

ENTRYPOINT ["make"]
