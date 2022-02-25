# Build
# docker build -t izissise/livereloadjs-bash .
# Run
# docker run --rm -ti --name 'livereloadjs-bash' -p 8080:8080 -p 34729:34729 -v 'RENDERED_STATIC_HTML_PATH:/www' izissise/livereloadjs-bash

FROM alpine:latest

ARG LIVERELOADJS_VERSION=3.3.3
ARG WEBSOCAT_VERSION=1.9.0
ARG MINISERVE_VERSION=0.18.0

# Static files
EXPOSE 8080/tcp
# livereloadjs Websocket
EXPOSE 34729/tcp

RUN apk add --no-cache \
      bash \
      jq \
      socat \
      inotify-tools

# livereloadjs client
ADD "https://raw.githubusercontent.com/livereload/livereload-js/v${LIVERELOADJS_VERSION}/dist/livereload.min.js" livereload.js

# websocat
ADD "https://github.com/vi/websocat/releases/download/v${WEBSOCAT_VERSION}/websocat_linux64" /bin/websocat
RUN chmod +x /bin/websocat

# miniserve
ADD "https://github.com/svenstaro/miniserve/releases/download/v${MINISERVE_VERSION}/miniserve-v${MINISERVE_VERSION}-x86_64-unknown-linux-musl" /bin/miniserve
RUN chmod +x /bin/miniserve

# Server script
COPY livereload.sh /bin/livereload.sh
RUN chmod +x /bin/livereload.sh

WORKDIR /
CMD ["livereload.sh"]
