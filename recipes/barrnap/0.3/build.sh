#!/bin/sh

mkdir -p $PREFIX/share/barrnap
mkdir -p $PREFIX/bin
cp ./binaries $PREFIX/share/barrnap/ -R
cp ./db $PREFIX/share/barrnap/ -R
cp ./barrnap $PREFIX/share/barrnap/
ln -s $PREFIX/share/barrnap/barrnap $PREFIX/bin/
