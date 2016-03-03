#!/bin/bash

BIN=$PREFIX/bin
mkdir -p $BIN
CXXFLAGS="-c $CXXFLAGS" make

cp skewer $BIN
