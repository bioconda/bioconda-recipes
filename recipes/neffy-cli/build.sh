#!/bin/bash -euo

set -xe

make

if [ ! -d ${PREFIX}/bin ] ; then
    mkdir -p ${PREFIX}/bin
fi

cp converter ${PREFIX}/bin
cp neff ${PREFIX}/bin
