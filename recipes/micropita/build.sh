#!/bin/bash

chmod +x *.py
mkdir -p ${PREFIX}/bin
cp *.py ${PREFIX}/bin/

cp -a src ${PREFIX}/bin/
