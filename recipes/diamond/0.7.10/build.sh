#!/bin/sh
cd src
./install-boost
make
mkdir -p $PREFIX
mv ../bin/diamond $PREFIX
