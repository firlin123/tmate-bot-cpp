#!/bin/bash

#wget https://raw.githubusercontent.com/firlin123/tmate-bot-cpp/master/setup.sh && sudo bash setup.sh

if [[ $EUID -ne 0 ]] || [ -z "$1" ]; then
    echo "No token or no root"
else
    OPW=$(pwd)
    TOKEN=$1
    cd /root
    apt install -y g++ make binutils cmake libssl-dev libboost-system-dev zlib1g-dev libcurl4-openssl-dev tmate git
    git clone https://github.com/firlin123/tmate-bot-cpp.git tgbot-cpp
    cd tgbot-cpp
    cmake .
    make -j4
    make install
    cd samples/echobot 
    cmake .
    make
    mkdir log
    touch allowed.txt
    cp my-rc-local.service /etc/systemd/system/
    echo 'cd /root
TOKEN='\"$TOKEN\"' /root/tgbot-cpp/samples/echobot/botstart.sh
cd $OPDPWD' > /etc/my-rc.local
    chmod +x /etc/my-rc.local
    systemctl start my-rc-local
    systemctl enable my-rc-local
    cd "$OPW"
fi
