#!/bin/sh

mkdir -p $PREFIX/bin

cp ./pipelines/GeneFamilyPhylogenyBuilder $PREFIX/bin
chmod +x $PREFIX/bin/GeneFamilyPhylogenyBuilder
