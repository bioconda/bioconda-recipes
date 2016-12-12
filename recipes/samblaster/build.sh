#!/bin/bash

BIN=$PREFIX/bin
mkdir -p $BIN
make
cp samblaster $BIN
