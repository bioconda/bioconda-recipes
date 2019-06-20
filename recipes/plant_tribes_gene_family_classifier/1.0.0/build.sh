#!/bin/sh

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/config
mkdir -p $PREFIX/data
mkdir -p $PREFIX/pipelines
mkdir -p $PREFIX/scripts

cp ./pipelines/GeneFamilyClassifier $PREFIX/bin
chmod +x $PREFIX/bin/GeneFamilyClassifier
ln -s $PREFIX/bin/GeneFamilyClassifier $PREFIX/pipelines/GeneFamilyClassifier
cp ./config/* $PREFIX/config
cp ./data/* $PREFIX/data
cp ./scripts/* $PREFIX/scripts
