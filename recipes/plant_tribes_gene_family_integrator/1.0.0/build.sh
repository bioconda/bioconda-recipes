#!/bin/sh

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/config
mkdir -p $PREFIX/data
mkdir -p $PREFIX/pipelines
mkdir -p $PREFIX/scripts

cp ./pipelines/GeneFamilyIntegrator $PREFIX/bin
chmod +x $PREFIX/bin/GeneFamilyIntegrator
ln -s $PREFIX/bin/GeneFamilyIntegrator $PREFIX/pipelines/GeneFamilyIntegrator
cp ./config/* $PREFIX/config
cp ./data/* $PREFIX/data
cp ./scripts/* $PREFIX/scripts
