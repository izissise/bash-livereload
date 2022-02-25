#!/bin/bash

set -euo pipefail

HTTP_LISTEN_PORT="${HTTP_LISTEN_PORT:="8080"}"  # miniserve listenport
WS_LISTEN_PORT="${WS_LISTEN_PORT:="34729"}"     # websocat listenport
INDEX_HTML="${INDEX_HTML:="index.html"}"        # miniserve index
LIVERELOAD="${LIVERELOAD:=true}"                # livereload on file modification
SPA="${SPA:=true}"                              # Single Page Application mode
QRCODE="${QRCODE:=false}"                       # Enable QR code display

# Path options
WWW_PATH="${WWW_PATH:="./www"}"                                   # Directory contains web source
LIVERELOADJS_PATH="${LIVERELOADJS_PATH:="./livereload.js"}"       # Path to livereload.js

INTERNAL_SERVE_PATH="${INTERNAL_SERVE_PATH:="./blivereloadserv"}" # Tmp dir include livereload.js on *.html

main() {
  local miniserve_pid=""
  local should_livereload="$LIVERELOAD"
  local miniserve_args=()
  "$SPA" && miniserve_args+=("--spa")
  "$QRCODE" && miniserve_args+=("--qrcode")


  # Websocket server func
  ws_server() {
    set -euo pipefail

    cmd_reload() {
      # Build json reload command
      jq -crn \
        --arg command 'reload' \
        --arg path "${1:-"/"}" \
        --arg liveCSS "${2:-true}" \
        --arg reloadMissingCSS "${3:-true}" \
        --arg liveIMG "${4:-true}" \
          '. | .["command"]=$command | .["path"]=$path | .["liveCSS"]=$liveCSS | .["reloadMissingCSS"]=$reloadMissingCSS | .["liveIMG"]=$liveIMG'
    }
    cmd_hello() {
      # Build json hello command
      jq -crn \
        --arg command 'hello' \
        --arg serverName "${1:-"dwl-reloader"}" \
        --arg protocols "${2:-"http://livereload.com/protocols/official-7"}" \
          '. | .["command"]=$command | .["serverName"]=$serverName | .["protocols"]=[$protocols]'
    }

    # SIGUSR1 => reload event
    trap cmd_reload SIGUSR1;

    # https://www.gnu.org/software/bash/manual/html_node/Signals.html#Signals
    jq --unbuffered -cr '.command' | while read -r cmd; do
      if [ "$cmd" = "hello" ]; then
        cmd_hello
      elif [ "$cmd" = "info" ]; then
        true
      else
        printf "%s\n" "docker web reload Unknown command ${cmd}"
      fi
    done &
    wait || true
  }
  export -f ws_server

  patch_livereload() {
      cp "$LIVERELOADJS_PATH" "$INTERNAL_SERVE_PATH"
      # find all html file and add livereload.js
      find "$INTERNAL_SERVE_PATH" -type f -name "*.html" -exec sed -i "s#</body>#</body>\\n<script src=\"livereload.js?port=${WS_LISTEN_PORT}\"></script>#" '{}' ";"
  }

  bootstrap() {
      mkdir -p "$INTERNAL_SERVE_PATH"
      # Copy file into serve directory
      cp  -rT "$WWW_PATH" "$INTERNAL_SERVE_PATH"
      if [ "$should_livereload" = "true" ]; then
          # Patch livereload
          patch_livereload
      fi

      # Run http server
      miniserve "${miniserve_args[@]}" --port "$HTTP_LISTEN_PORT" --index "${INDEX_HTML}" "$INTERNAL_SERVE_PATH" &
      if [ "$should_livereload" = "true" ]; then
          sleep 0.1
          # Send signal to websocket servers
          pkill -USR1 -fx '/bin/bash -c ws_server' || true
      fi
  }

  if [ "$should_livereload" = "true" ]; then
      # Start websocat to spawn ws_server func on each new client
      (socat TCP-LISTEN:11111,reuseaddr,fork,crlf exec:"/bin/bash -c ws_server") &
      (websocat --exit-on-eof --text "ws-listen:0.0.0.0:${WS_LISTEN_PORT}" tcp:127.0.0.1:11111) &
  fi

  while true; do
      bootstrap
      sleep 0.1
      # Build file watch list
      readarray -d $'\0' -t watch_arr < <(find "$WWW_PATH" -print0)
      printf '%b%s%b' "\e[34m" "Waiting for file changes" "\e[0m\n"
      inotifywait -e modify "${watch_arr[@]}" > /dev/null 2>&1
      sleep 0.6
      printf '%b%s%b' "\e[34m" "File modified restarting" "\e[0m\n"
      pkill -TERM "miniserve"
  done
}

exist() {
    command -v "$1" >/dev/null 2>&1 || { printf >&2 "%s\n" "$1 is required but it's not installed."; exit 1; }
}

for c in jq find grep miniserve websocat cp socat inotifywait mkdir pkill; do
  exist "$c"
done

main
