#TODO lighter baseimage
#TODO publish git/docker repo
#TODO blog use gpt-3
# Build
# docker build -t docker build -t izissise/bash-livereload .
# Run
# docker run --rm -ti --name 'bash-livereload' -p 8080:8080 -p 34729:34729 -v 'RENDERED_STATIC_HTML_PATH:/www' izissise/bash-livereload

FROM ubuntu:bionic

ARG LIVERELOADJS_VERSION=3.3.3
ARG WEBSOCAT_VERSION=1.9.0
ARG MINISERVE_VERSION=0.18.0

# Static file
EXPOSE 8080/tcp
 # Websocket livereload
EXPOSE 34729/tcp

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        jq \
        socat \
        inotify-tools \
      && \
    apt-get autoremove --purge -y && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/*

# Live reload client
ADD "https://raw.githubusercontent.com/livereload/livereload-js/v${LIVERELOADJS_VERSION}/dist/livereload.min.js" livereload.js

# Add websocat
ADD "https://github.com/vi/websocat/releases/download/v${WEBSOCAT_VERSION}/websocat_linux64" /bin/websocat
RUN chmod +x /bin/websocat

# Http server
ADD "https://github.com/svenstaro/miniserve/releases/download/v${MINISERVE_VERSION}/miniserve-v${MINISERVE_VERSION}-x86_64-unknown-linux-musl" /bin/miniserve
RUN chmod +x /bin/miniserve

COPY livereload.sh /bin/livereload.sh
RUN chmod +x /bin/livereload.sh

WORKDIR /
CMD ["livereload.sh"]
