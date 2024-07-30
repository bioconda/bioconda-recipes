#!/bin/bash

wget https://downloads.haskell.org/~ghc/9.4.7/ghc-9.4.7-x86_64-centos7-linux.tar.xz
tar xf ghc-9.4.7-x86_64-centos7-linux.tar.xz

cd ghc-9.4.7-x86_64-unknown-linux
echo "### CONFIGURING GHC compilation"
./configure --prefix=$PREFIX

echo "### MAKE INSTALL GHC"
make install

stack install --local-bin-path ${PREFIX}/bin --system-ghc --no-install-ghc
