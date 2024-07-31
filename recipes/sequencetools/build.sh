#!/bin/bash

GHC_VERSION=9.4.7

# Download GHC
GHC_URL=https://downloads.haskell.org/~ghc/$GHC_VERSION/ghc-$GHC_VERSION-src.tar.xz
echo "Downloading $GHC_URL"
wget $GHC_URL

echo "Unpacking $GHC_URL"
tar xf ghc-$GHC_VERSION-src.tar.xz

echo "ls:"
ls

# Compile GHC
DIR=ghc-$GHC_VERSION
echo "Compiling GHC in $DIR"
cd $DIR
echo "Configuring GHC"
./configure --prefix=$PREFIX

echo "building GHC"
make install

# Run Stack
echo "Running Stack"
stack install --local-bin-path ${PREFIX}/bin --system-ghc --no-install-ghc
