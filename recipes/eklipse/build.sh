#!/bin/bash
curl -SL https://github.com/dooguypapua/eKLIPse/archive/refs/heads/master.zip -o eklipse.zip
unzip -d eklipse eklipse.zip
cd eklipse/eKLIPse-master
chmod +x eKLIPse.py
sed -i '1s|.*|#!/usr/bin/env python2\n&|' eKLIPse.py
mkdir -p ${PREFIX}/bin
cp -r data/* doc/* *py  ${PREFIX}/bin/
