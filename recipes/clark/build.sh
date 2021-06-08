#!/bin/bash

mkdir -p $PREFIX/bin

sed -i.bak "s|g++|$CXX|g" install.sh
sed -i.bak "s|cpp |$CXX |g" install.sh
./install.sh

mv install.sh install.sh.old

mv exe/* $PREFIX/bin

mkdir -p $PREFIX/opt/clark
mv *.sh $PREFIX/opt/clark
cd $PREFIX/opt/clark
ln -s $PREFIX/bin exe
