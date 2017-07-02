#!/bin/sh

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/config
mkdir -p $PREFIX/data
mkdir -p $PREFIX/pipelines
mkdir -p $PREFIX/scripts

cp ./pipelines/GeneFamilyPhylogenyBuilder $PREFIX/bin
chmod +x $PREFIX/bin/GeneFamilyPhylogenyBuilder
ln -s $PREFIX/bin/GeneFamilyPhylogenyBuilder $PREFIX/pipelines/GeneFamilyPhylogenyBuilder
cp ./config/* $PREFIX/config
cp ./data/* $PREFIX/data
cp ./scripts/* $PREFIX/scripts
