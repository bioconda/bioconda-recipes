#!/bin/sh

mkdir -p $PREFIX/bin

cp ./pipelines/GeneFamilyAligner $PREFIX/bin
chmod +x $PREFIX/bin/GeneFamilyAligner
