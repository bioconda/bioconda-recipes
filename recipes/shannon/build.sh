#!/bin/bash
mkdir -p $PREFIX/bin
cp *.py $PREFIX/bin
cp manual.md $PREFIX/bin
chmod a+x $PREFIX/bin/shannon.py
