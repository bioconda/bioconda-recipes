#!/bin/bash
mkdir -p $PREFIX/bin/cm
cp reago.py $PREFIX/bin
cp filter_input.py $PREFIX/bin
cp -r cm/* $PREFIX/bin/cm

chmod +x $PREFIX/bin/reago.py
chmod +x $PREFIX/bin/filter_input.py