#!/bin/sh

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/config
mkdir -p $PREFIX/data

cp ./pipelines/GeneFamilyClassifier $PREFIX/bin
chmod +x $PREFIX/bin/GeneFamilyClassifier
cp ./config/* $PREFIX/config
cp ./data/* $PREFIX/data
