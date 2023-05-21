#!/bin/bash

mkdir -p ${PREFIX}/bin

# change path for Lordec binaries
sed -i.bak 's/\$DIR\/LoRDEC/\$DIR/' lorma.sh

# copy shell script
cp lorma.sh ${PREFIX}/bin

mkdir build
cd build

cmake ..
make

#copy binary
cp LoRMA ${PREFIX}/bin
