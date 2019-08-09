#!/bin/bash
make
mkdir -p $PREFIX/bin
cp bin/strike $PREFIX/bin/strike
chmod +x $PREFIX/bin/strike