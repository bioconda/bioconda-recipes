#!/bin/bash

GHC_VERSION=9.4.7

# Download GHC
wget https://downloads.haskell.org/~ghc/$GHC_VERSION/ghc-$GHC_VERSION-src.tar.xz
tar xf ghc-$GHC_VERSION-src.tar.xz

# Compile GHC
cd ghc-$GHC_VERSION
./configure --prefix=$PREFIX
make install

# Run Stack
stack install --local-bin-path ${PREFIX}/bin --system-ghc --no-install-ghc
