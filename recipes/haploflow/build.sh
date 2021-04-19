#!/bin/bash

echo "Build assumes Ubuntu >= 14.04"

sudo apt install cmake libboost-all-dev ruby-ronn git build-essential

DIR=`pwd`

mkdir -p build
cd build
cmake ..
make

sudo cp haploflow /usr/local/bin

cd ..
ln -sf README.md haploflow.md
ronn -r --pipe haploflow.md > haploflow.1
mkdir -p /usr/local/man/man1
sudo cp haploflow.1 /usr/local/man/man1

cd /
tar czvf $DIR/build/haploflow.tar.gz usr/local/bin/haploflow usr/local/man/man1/haploflow.1