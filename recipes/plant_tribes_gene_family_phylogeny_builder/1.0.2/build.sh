#!/bin/sh

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/config
mkdir -p $PREFIX/data

cp ./pipelines/GeneFamilyPhylogenyBuilder $PREFIX/bin
chmod +x $PREFIX/bin/GeneFamilyPhylogenyBuilder
cp ./config/* $PREFIX/config
cp ./data/* $PREFIX/data
