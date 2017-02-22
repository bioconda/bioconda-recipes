#!/bin/sh

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/config
mkdir -p $PREFIX/data
mkdir -p $PREFIX/pipelines
mkdir -p $PREFIX/scripts

cp ./pipelines/PhylogenomicsAnalysis $PREFIX/bin
ln -s $PREFIX/bin/PhylogenomicsAnalysis $PREFIX/pipelines/PhylogenomicsAnalysis
cp ./config/* $PREFIX/config
cp ./data/* $PREFIX/data
cp ./scripts/* $PREFIX/scripts
chmod +x $PREFIX/bin/PhylogenomicsAnalysis

