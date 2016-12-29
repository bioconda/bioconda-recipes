#!/bin/bash

set -e

HAPDIP=https://raw.githubusercontent.com/lh3/hapdip/864755b1b9160f5a3faaaf53a0e35feccbc7f1fd/hapdip.js
HAPDIP_SHA256=864330aa288f86befa45af23802b5ffe852254baabd8e28595d571898b369402
mkdir -p $PREFIX/bin

make fermi.kit/k8
mv fermi.kit/k8 run-calling $PREFIX/bin
curl -k $HAPDIP -o $PREFIX/bin/hapdip.js
if [[ "$(shasum -a 256 $PREFIX/bin/hapdip.js|cut -f1 -d ' ')" != "$HAPDIP_SHA256" ]]
then
    echo "Downloaded hapdip.js file does not match checksum"
    exit 1
fi

