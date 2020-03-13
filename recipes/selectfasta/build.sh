#!/bin/bash
echo "selectFasta compilation"
make
mkdir -p $PREFIX/bin
cp selectFasta $PREFIX/bin
echo "Installation successful"

