#!/bin/bash

set -e

mkdir -p ${PREFIX}/bin
chmod -R +x sraXlib
chmod +x sraX
cp -r sraXlib ${PREFIX}/bin
cp sraX ${PREFIX}/bin
