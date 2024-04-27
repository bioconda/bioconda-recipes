#!/bin/bash

perl Makefile.PL
make
make install

mkdir -p ${PREFIX}/bin 
cp -v SneakerNet.plugins/*.pl ${PREFIX}/bin/
cp -v SneakerNet.plugins/*.py ${PREFIX}/bin/
cp -v SneakerNet.plugins/*.sh ${PREFIX}/bin/
cp -v scripts/*.pl            ${PREFIX}/bin/
chmod 775 ${PREFIX}/bin/*

