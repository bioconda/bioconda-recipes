#!/bin/bash
chmod +x ./install.sh
./install.sh
mkdir -p ${PREFIX}/bin
cp vargeno ${PREFIX}/bin
chmod +x ${PREFIX}/bin/vargeno
