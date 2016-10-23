#!/bin/bash


cd src/
make
make install
cd ..
cp bin/* ${PREFIX}/bin
