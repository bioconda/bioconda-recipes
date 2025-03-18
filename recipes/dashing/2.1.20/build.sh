#!/bin/bash


make -j4
mkdir -p $PREFIX/bin
cp -r dashing2 dashing2-64 dashing2-tmp $PREFIX/bin
chmod +x $PREFIX/bin/{dashing2,dashing2-64,dashing2-tmp}
