#!/bin/bash

python2.7 -m pip install --user intervaltree
python2.7 -m pip install --user blosc
wget https://bootstrap.pypa.io/get-pip.py
pypy get-pip.py
pypy -m pip install --user intervaltree
pypy -m pip install --user blosc

mkdir -pv $PREFIX/bin
cp -rv clairvoyante dataPrepScripts $PREFIX/bin
cp clairvoyante.py $PREFIX/bin/

