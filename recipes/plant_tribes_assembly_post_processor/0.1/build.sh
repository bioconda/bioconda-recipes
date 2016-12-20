#!/bin/sh

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/config

cp ./pipelines/AssemblyPostProcesser $PREFIX/bin
cp ./config/plantTribes.config $PREFIX/config
