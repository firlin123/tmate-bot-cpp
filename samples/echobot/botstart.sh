#!/bin/bash

function check_conn(){
  timeout 5 wget -q --spider https://telegram.org/

  if [ $? -eq 0 ]; then
    echo "Online"
  else
    echo "Offline"
  fi
}

function infinite(){
  while true; do
    if [ "$(check_conn)" != "Online" ]; then
      echo $(date +"[%Y.%m.%d %T]")" Offline"
    else
      echo $(date +"[%Y.%m.%d %T]") "Online"
      timeout -s SIGINT 20m stdbuf -o0 -e0 /root/tgbot-cpp/samples/echobot/echobot
    fi
    sleep 5
  done
}

File_Date=$(date +"%Y.%m.%d-%H.%M.%S")
infinite 2>&1 >/root/tgbot-cpp/samples/echobot/log/echobot-$File_Date.log &
