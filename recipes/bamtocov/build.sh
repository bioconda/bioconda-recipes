#!/bin/sh
set -euxo pipefail

if [[ $OSTYPE == "darwin"* ]]; then
  # export HOME="/Users/distiller"
  export HOME=`pwd`
fi
 
 
export LD_LIBRARY_PATH="$PREFIX"/lib


# nimble install -y --verbose
nimble build -y --verbose  -d:release --opt:speed
mkdir -p "$PREFIX"/bin

pwd
ls -l bin/* 

# Copy binaries
chmod a+x bin/* 
cp bin/* "$PREFIX"/bin/ 

# Auxiliary python scripts
chmod a+x scripts/*.py
cp scripts/*.py "$PREFIX"/bin
