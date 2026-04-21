FROM debian:trixie-slim
RUN apt-get update -qq \
 && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        debhelper \
        devscripts \
        git \
        git-buildpackage \
        gnupg \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /build
