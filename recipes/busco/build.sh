#!/bin/bash

mkdir -p $PREFIX/bin/
cp BUSCO_v1.2.py $PREFIX/bin
ln -s $PREFIX/bin/BUSCO_v1.2.py $PREFIX/bin/BUSCO_v1.1b1.py
