#!/bin/sh

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/config
mkdir -p $PREFIX/data

cp ./pipelines/GeneFamilyIntegrator $PREFIX/bin
chmod +x $PREFIX/bin/GeneFamilyIntegrator
cp ./config/* $PREFIX/config
cp ./data/* $PREFIX/data
