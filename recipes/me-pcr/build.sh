#!/bin/bash

make CC=$CC CPP=$CXX -C src/ -f makefile

mkdir -p $PREFIX/share/me-pcr/
cp README.txt $PREFIX/share/me-pcr/

mkdir -p $PREFIX/bin
chmod +x src/me-PCR
cp src/me-PCR $PREFIX/bin/
