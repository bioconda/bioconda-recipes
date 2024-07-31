#!/bin/bash

GHC_VERSION=9.4.7

echo "Build Platform"
echo $build_platform

# Download GHC
if [ "$build_platform" == "linux-64"]; then
    GHC_URL=https://downloads.haskell.org/~ghc/$GHC_VERSION/ghc-$GHC_VERSION-x86_64-centos7-linux.tar.xz
elif [ "$build_platform" == "osx-64"]; then
    GHC_URL=https://downloads.haskell.org/~ghc/$GHC_VERSION/ghc-$GHC_VERSION-x86_64-apple-darwin.tar.xz
fi
echo "Downloading $GHC_URL"
wget $GHC_URL

echo "Unpacking $GHC_URL"
tar xf ghc-$GHC_VERSION-src.tar.xz

# Compile GHC
DIR=$(ls ghc-$GHC_VERSION*)
echo "Compiling GHC in $DIR"
cd $DIR
echo "Configuring GHC"
./configure --prefix=$PREFIX

echo "building GHC"
make install

# Run Stack
echo "Running Stack"
stack install --local-bin-path ${PREFIX}/bin --system-ghc --no-install-ghc
