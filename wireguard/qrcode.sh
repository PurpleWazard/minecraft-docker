$!/bin/bash

if [ $(qrencode -V) ]; then
    qrencode -t ansiuft8 < config/client.conf
else
    echo " qrencode is not installed "
    exit 1
fi
