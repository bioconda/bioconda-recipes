#!/bin/bash
mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/lib/python2.7/site-packages/paleomix
cp paleomix/main.py $PREFIX/bin/main.py
cp -r paleomix $PREFIX/lib/python2.7/site-packages/paleomix
