#!/bin/bash

mkdir ${PREFIX}/sativa/
mv * ${PREFIX}/sativa/
cd ${PREFIX}/sativa
./install.sh
cd ${PREFIX}/bin
ln -s ${PREFIX}/sativa/sativa.py .
