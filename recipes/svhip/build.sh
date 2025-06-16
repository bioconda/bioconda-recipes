#!/bin/bash

THIS_DIR=$(basename $(pwd))
cd ..
mkdir -p $PREFIX/share
cp -r $THIS_DIR $PREFIX/share/Svhip

mkdir -p $PREFIX/bin/
echo "#! /usr/bin/env bash" >> $PREFIX/bin/svhip
echo "SHARE_DIR=$PREFIX/share/Svhip" >> $PREFIX/bin/svhip
head -1 $PREFIX/share/Svhip/run_svhip.sh >> $PREFIX/bin/svhip 
chmod +x $PREFIX/bin/svhip
