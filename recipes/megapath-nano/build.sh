#!/bin/bash

mkdir -pv $PREFIX/bin
mkdir -pv $PREFIX/MegaPath-Nano
cp -rv bin db_preparation docs Dockerfile README.md LICENSE $PREFIX/MegaPath-Nano
ln -s $PREFIX/MegaPath-Nano/bin/megapath_nano.py $PREFIX/bin
ln -s $PREFIX/MegaPath-Nano/bin/megapath_nano_amr.py $PREFIX/bin
