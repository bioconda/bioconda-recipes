#!/bin/sh

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/config
mkdir -p $PREFIX/data
mkdir -p $PREFIX/pipelines
mkdir -p $PREFIX/scripts

cp ./pipelines/AssemblyPostProcessor $PREFIX/bin
chmod +x $PREFIX/bin/AssemblyPostProcessor
ln -s $PREFIX/bin/AssemblyPostProcessor $PREFIX/pipelines/AssemblyPostProcessor
cp ./config/* $PREFIX/config
cp ./data/* $PREFIX/data
cp ./scripts/* $PREFIX/scripts
