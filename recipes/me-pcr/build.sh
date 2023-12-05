#!/bin/bash

make CC=$CC CPP=$CXX -C src/ -f makefile

mkdir -p $PREFIX/share/doc/me-pcr/
cp README.txt $PREFIX/share/doc/me-pcr/

mkdir -p $PREFIX/bin
chmod +x src/me-PCR
cp src/me-PCR $PREFIX/bin/
