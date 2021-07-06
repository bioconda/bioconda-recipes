#!/bin/bash

sed -i '1d' Makefile

make
chmod +x srnaMapper
mkdir -p ${PREFIX}/bin
cp -f srnaMapper ${PREFIX}/bin
