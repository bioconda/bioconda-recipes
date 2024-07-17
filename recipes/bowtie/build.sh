#!/bin/bash

if [ "$(uname -m)" == "arm64" ]; then
    make POPCNT_CAPABILITY=0
fi

make prefix="${PREFIX}" install

cp -r scripts "${PREFIX}/bin/"
