#!/bin/sh

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/config
mkdir -p $PREFIX/data
mkdir -p $PREFIX/pipelines
mkdir -p $PREFIX/scripts

cp ./pipelines/AssemblyPostProcesser $PREFIX/bin
ln -s $PREFIX/bin/AssemblyPostProcesser $PREFIX/pipelines/AssemblyPostProcesser
cp ./config/* $PREFIX/config
cp ./data/* $PREFIX/data
cp ./scripts/* $PREFIX/scripts
