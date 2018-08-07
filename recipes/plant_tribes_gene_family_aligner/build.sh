#!/bin/sh

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/config
mkdir -p $PREFIX/data
mkdir -p $PREFIX/pipelines
mkdir -p $PREFIX/scripts

cp ./pipelines/GeneFamilyAligner $PREFIX/bin
chmod +x $PREFIX/bin/GeneFamilyAligner
ln -s $PREFIX/bin/GeneFamilyAligner $PREFIX/pipelines/GeneFamilyAligner
cp ./config/* $PREFIX/config
cp ./data/* $PREFIX/data
cp ./scripts/* $PREFIX/scripts
