#!/bin/bash
mkdir -p $PREFIX/bin

cp -r mixEM $PREFIX/bin
cp -r refs $PREFIX/bin
cp -r web_summary $PREFIX/bin
cp *.py $PREFIX/bin

# longQC.py has no shebang upstream; add one so it can be run directly
sed -i.bak '1{s;^;#!/usr/bin/env python\n;}' $PREFIX/bin/longQC.py
rm $PREFIX/bin/longQC.py.bak
chmod +x $PREFIX/bin/longQC.py
