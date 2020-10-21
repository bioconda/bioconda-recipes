#!/bin/sh

mkdir -p $PREFIX/bin

cp ./pipelines/AssemblyPostProcessor $PREFIX/bin
chmod +x $PREFIX/bin/AssemblyPostProcessor
