#!/bin/bash

# Download GHC
wget https://downloads.haskell.org/~ghc/9.4.7/ghc-9.4.7-src.tar.xz
tar xf ghc-9.4.7-src.tar.xz

# Compile GHC
cd ghc-9.4.7
./configure --prefix=$PREFIX
make install

# Run Stack
stack install --local-bin-path ${PREFIX}/bin --system-ghc --no-install-ghc
