#!/bin/sh

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/config
mkdir -p $PREFIX/data

cp ./pipelines/AssemblyPostProcessor $PREFIX/bin
chmod +x $PREFIX/bin/AssemblyPostProcessor
cp ./config/* $PREFIX/config
cp ./data/* $PREFIX/data
