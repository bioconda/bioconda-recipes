#!/bin/bash

curl -SL https://github.com/dooguypapua/eKLIPse/archive/refs/heads/master.zip -o eklipse.zip

unzip -d eklipse eklipse.zip
cd eklipse
mkdir -p ${PREFIX}/bin
cp -r eKLIPse-master/*.py ${PREFIX}/bin/
chmod +x ${PREFIX}/bin/eKLIPse.py
