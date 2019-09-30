#!/bin/bash

mkdir -p ${PREFIX}/bin
make
cp codonw ${PREFIX}/bin
for link in rscu cu aau raau tidy reader cutab cutot transl bases base3s dinuc cai fop gc3s gc cbi enc; do
    ln -s ${PREFIX}/bin/codonw ${PREFIX}/bin/${link}
done
