#!/bin/bash
Socket_Name="/tmp/tmate-$(cat /dev/urandom | tr -cd 'a-f0-9' | head -c 16).sock"

Socket_Exists="false"
Multiple_Sockets="false"
for Socket in /tmp/tmate-*.sock
do
  if [ -S $Socket ]; then
    if [ "$Socket_Exists" == "false" ]; then
      Socket_Exists="true"
      Socket_Name=$Socket
    else
      Multiple_Sockets="true"
    fi
  fi
done

if [ "$Multiple_Sockets" == "true" ]; then
  >&2 echo "Multiple sessions detcted. Picking first one."
fi
if [ "$Socket_Exists" == "false" ]; then
  >&2 echo "New session"
  tmate -S $Socket_Name new-session -d
  tmate -S $Socket_Name wait tmate-ready
fi


tmate -S $Socket_Name display -p '#{tmate_ssh}'
