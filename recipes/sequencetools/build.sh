#!/bin/bash

# Download GHC
wget https://downloads.haskell.org/~ghc/9.4.7/ghc-9.4.7-x86_64-centos7-linux.tar.xz
tar xf ghc-9.4.7-x86_64-centos7-linux.tar.xz

# Compile GHC
cd ghc-9.4.7-x86_64-unknown-linux
./configure --prefix=$PREFIX
make install

# Run Stack
stack install --local-bin-path ${PREFIX}/bin --system-ghc --no-install-ghc
