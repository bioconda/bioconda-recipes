#!/bin/sh
set -euxo pipefail

if [[ $OSTYPE == "darwin"* ]]; then
  export HOME="/Users/distiller"
fi
 
 
export LD_LIBRARY_PATH=$PREFIX/lib

nimble install -y --verbose
mkdir -p $PREFIX/bin

pwd
ls -l bin/* 

chmod a+x bin/* 
cp bin/* "$PREFIX"/bin/ 