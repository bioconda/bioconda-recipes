#!/bin/bash
./make.sh
mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin
