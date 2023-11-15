#!/bin/sh

set -euxo pipefail

echo "--- NIM BUILD ---"
nim --version
echo "----------"
nimble --version
echo "----------"

echo "GXX: $GXX"
echo "GCC: $GCC"

# Trying to fix build
sed -i 's/gcc/$(GCC)/g' Makefile
sed -i 's/g++/$(GXX)/g' Makefile
sed -i '1iGCC ?= gcc' Makefile
sed -i '1iGXX ?= g++' Makefile

if [[ $OSTYPE == "darwin"* ]]; then
  export HOME="/Users/distiller"
  export HOME=`pwd`
fi

mkdir -p "$PREFIX"/bin

echo "## Automatic build: install deps"
#nimble build -y --verbose 
nimble install -y --depsOnly
echo "## Automatic build: make"
make

./bin/seqfu version || true


# Not necessary using `make`
#if [[ -d scripts ]]; then
#  echo "## Copying utils"
#  chmod +x scripts/*
#  cp scripts/* bin/
#fi

echo "## Current dir: $(pwd)"
mv bin/* "$PREFIX"/bin/


echo "## List files in \$PREFIX/bin:"
ls -ltr "$PREFIX"/bin/
 
