#!/bin/bash

set -xe

if [ "$(uname -m)" == "arm64" ]; then
    make POPCNT_CAPABILITY=0 -j ${CPU_COUNT}
fi

make prefix="${PREFIX}"  -j ${CPU_COUNT} install

cp -r scripts "${PREFIX}/bin/"
