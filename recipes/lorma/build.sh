#!/bin/bash

mkdir -p ${PREFIX}/bin

# change paths for binaries
sed -i.bak 's/\$DIR\/LoRDEC/\$DIR/' lorma.sh
sed -i.bak 's/\$DIR\/LoRMA/\$DIR/' lorma.sh
cp lorma.sh ${PREFIX}/bin

mkdir build
cd build

cmake ..
make

cp build/LoRMA ${PREFIX}/bin
