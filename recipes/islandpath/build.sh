#!/usr/bin/env bash
mkdir -p $PREFIX/opt/islandpath
cp -r . $PREFIX/opt/islandpath
mkdir -p $PREFIX/bin
ln -s $PREFIX/opt/islandpath/Dimob.pl $PREFIX/bin/islandpath
chmod +x $PREFIX/bin/*
