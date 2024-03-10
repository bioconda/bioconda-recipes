#!/bin/bash

mkdir -p ${PREFIX}/bin
cp -r FAVITES-Lite-* ${PREFIX}/bin/FAVITES-Lite
ln -s ${PREFIX}/bin/FAVITES-Lite/favites_lite.py ${PREFIX}/bin/favites_lite.py
