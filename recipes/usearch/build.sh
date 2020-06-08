#!/bin/bash

gunzip "usearch"$PKG_VERSION"_i86linux32.gz"
chmod +x "usearch"$PKG_VERSION"_i86linux32"
mv "usearch"$PKG_VERSION"_i86linux32" usearch
mkdir -p $PREFIX/bin
cp usearch $PREFIX/bin
