#!/bin/sh
set -euxo pipefail

if [[ $OSTYPE == "darwin"* ]]; then
  # export HOME="/Users/distiller"
  export HOME=`pwd`
fi
 
 
export LD_LIBRARY_PATH="$PREFIX"/lib


# nimble install -y --verbose
nimble build -y --verbose -d:static -d:release --opt:speed
mkdir -p "$PREFIX"/bin

pwd
ls -l bin/* 

chmod a+x bin/* 
cp bin/* "$PREFIX"/bin/ 
