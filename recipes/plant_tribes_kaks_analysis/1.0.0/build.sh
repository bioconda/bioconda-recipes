#!/bin/sh

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/config
mkdir -p $PREFIX/data
mkdir -p $PREFIX/pipelines
mkdir -p $PREFIX/scripts

cp ./pipelines/KaKsAnalysis $PREFIX/bin
chmod +x $PREFIX/bin/KaKsAnalysis
ln -s $PREFIX/bin/KaKsAnalysis $PREFIX/pipelines/KaKsAnalysis
cp ./config/* $PREFIX/config
cp ./data/* $PREFIX/data
cp ./scripts/* $PREFIX/scripts
