#!/bin/bash

BIN=$PREFIX/bin
mkdir -p $BIN
make
cp modbam2bed $BIN
