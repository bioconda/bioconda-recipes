#!/bin/bash

mkdir -p ${PREFIX}/bin
cd src/
make
cp ../bin/tandem.exe ${PREFIX}/bin/xtandem
