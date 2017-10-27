#!/bin/sh

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/config
mkdir -p $PREFIX/data

cp ./pipelines/KaKsAnalysis $PREFIX/bin
chmod +x $PREFIX/bin/KaKsAnalysis
cp ./config/* $PREFIX/config
cp ./data/* $PREFIX/data
