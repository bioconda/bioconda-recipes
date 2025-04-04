#!/bin/bash

mkdir -p ${PREFIX}/bin/FAVITES-Lite
cp -r * ${PREFIX}/bin/FAVITES-Lite/
ln -s ${PREFIX}/bin/FAVITES-Lite/favites_lite.py ${PREFIX}/bin/favites_lite.py
