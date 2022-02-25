


docker run --rm -ti --name 'livereloadjs-bash' -p 8080:8080 -p 34729:34729 -v 'RENDERED_STATIC_HTML_PATH:/www' izissise/livereloadjs-bash

HTTP_LISTEN_PORT="${HTTP_LISTEN_PORT:="8080"}"  # miniserve listenport
WS_LISTEN_PORT="${WS_LISTEN_PORT:="34729"}"     # websocat listenport
INDEX_HTML="${INDEX_HTML:="index.html"}"        # miniserve index
LIVERELOAD="${LIVERELOAD:=true}"                # livereload on file modification
SPA="${SPA:=true}"                              # Single Page Application mode
QRCODE="${QRCODE:=false}"                       # Enable QR code display

# Path options
WWW_PATH="${WWW_PATH:="./www"}"                                   # Directory contains web source
LIVERELOADJS_PATH="${LIVERELOADJS_PATH:="./livereload.js"}"       # Path to livereload.js
