#!/bin/bash
mkdir ${PREFIX}/bin
chmod +x *.py
cp *.py ${PREFIX}/bin

chmod +x src/*.py
cp src/*.py ${PREFIX}/bin
