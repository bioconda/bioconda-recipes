#!/bin/bash

sed -i 's|gcc|cc|' makefile

make
chmod +x srnaMapper
mkdir -p ${PREFIX}/bin
cp -f srnaMapper ${PREFIX}/bin
