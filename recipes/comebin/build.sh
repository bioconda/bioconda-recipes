#!/usr/bin/env bash

mkdir -p $PREFIX/bin/ 
cp -r COMEBin $PREFIX/bin/
cp -r auxiliary $PREFIX/bin/
cp bin/run_comebin.sh $PREFIX/bin/
chmod a+x $PREFIX/bin/run_comebin.sh

