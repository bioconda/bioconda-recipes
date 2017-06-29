#!/bin/sh

mkdir -p $PREFIX/share/barrnap
mkdir -p $PREFIX/bin
cp -R ./binaries $PREFIX/share/barrnap/
cp -R ./db $PREFIX/share/barrnap/
cp ./barrnap $PREFIX/share/barrnap/
ln -s $PREFIX/share/barrnap/barrnap $PREFIX/bin/
