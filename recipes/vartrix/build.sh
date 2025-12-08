#!/bin/bash -euo

mkdir -p ${PREFIX}/bin

mv vartrix_* vartrix
chmod 755 vartrix
cp -f vartrix ${PREFIX}/bin
