#!/bin/bash

BIN=$PREFIX/bin
mkdir -p $BIN

sed '1 s/^.*$/CXX=${CXX}/' Makefile

CXXFLAGS="-c $CXXFLAGS" make

cp skewer $BIN
