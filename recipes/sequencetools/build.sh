#!/bin/bash

GHC_VERSION=9.4.7

echo "================== BUILD PLATFORM =================="
echo $build_platform # can be "linux-64, osx-64, osx-arm64"

# Download GHC
if [ "$build_platform" == "linux-64" ]; then
    GHC_TAR=ghc-$GHC_VERSION-x86_64-centos7-linux.tar.xz
elif [ "$build_platform" == "osx-64" ]; then
    GHC_TAR=ghc-$GHC_VERSION-x86_64-apple-darwin.tar.xz
elif [ "$build_platform" == "osx-arm64" ]; then
    GHC_TAR=ghc-$GHC_VERSION-aarch64-apple-darwin.tar.xz    
fi

GHC_URL=https://downloads.haskell.org/~ghc/$GHC_VERSION/$GHC_TAR
echo "================== Downloading $GHC_URL =================="
wget $GHC_URL

echo "================== Unpacking $GHC_TAR =================="
tar xf $GHC_TAR

# Compile GHC
DIR=$(tar -tf $GHC_TAR | head -1) # this just looks for the name of the unpacked GHC directory from the tar-ball
echo "================== Compiling GHC in $DIR =================="
cd $DIR
echo "================== Configuring GHC =================="
./configure --prefix=$PREFIX

echo "================== building GHC =================="
make install

# Run Stack
echo "================== Running Stack =================="
stack install --local-bin-path ${PREFIX}/bin --system-ghc --no-install-ghc
