#!/bin/bash

mkdir -p ${PREFIX}/bin

# change paths for binaries
sed -i.bak 's/\$DIR\/LoRDEC/\$DIR/' lorma.sh
sed -i.bak 's/\$DIR\/LoRMA/\$DIR/' lorma.sh

# copy shell script
cp lorma.sh ${PREFIX}/bin

mkdir build
cd build

cmake ..
make

#copy binary
cp LoRMA ${PREFIX}/bin
