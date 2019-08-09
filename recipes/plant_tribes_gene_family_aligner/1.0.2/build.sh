#!/bin/sh

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/config
mkdir -p $PREFIX/data

cp ./pipelines/GeneFamilyAligner $PREFIX/bin
chmod +x $PREFIX/bin/GeneFamilyAligner
cp ./config/* $PREFIX/config
cp ./data/* $PREFIX/data
