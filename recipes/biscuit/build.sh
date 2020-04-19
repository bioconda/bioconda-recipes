#!/bin/bash

BIN=$PREFIX/bin
mkdir -p $BIN
sed -i.bak 's/CPPFLAGS = /CPPFLAGS = $(CXXFLAGS) /' Makefile
make CPP=$CXX
cp biscuit $BIN