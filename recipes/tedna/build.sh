#!/bin/bash

# fix makefile
sed -i.bak 's|CFLAGS = |CFLAGS = -I'$PREFIX'/include/ |' makefile

# make
make

# copy binary
cp ./tedna $PREFIX/bin
