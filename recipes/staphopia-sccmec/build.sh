#!/bin/bash

mkdir -p $PREFIX/bin
chmod 755 bin/staphopia-sccmec.py
cp -f bin/staphopia-sccmec.py $PREFIX/bin/staphopia-sccmec

# Move data
mkdir -p $PREFIX/share
cp -r share/staphopia-sccmec $PREFIX/share/
