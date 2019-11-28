#!/bin/sh

mkdir -p $PREFIX/bin

cp ./pipelines/GeneFamilyClassifier $PREFIX/bin
chmod +x $PREFIX/bin/GeneFamilyClassifier
