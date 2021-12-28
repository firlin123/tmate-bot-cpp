#!/bin/bash

User_ID=$1
Bot_Path="/root/tgbot-cpp/samples/echobot"
Allowed="false"

while read Current_ID
do
    if [ "$User_ID" == "$Current_ID" ]; then
      Allowed="true"
    fi
done < "$Bot_Path/allowed.txt"

if [ "$Allowed" == "true" ]; then
  echo "allowed"
fi

echo $(date +"%D %T")" $User_ID: $Allowed" >> "$Bot_Path/log/allowed.log"
