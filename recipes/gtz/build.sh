#!/bin/sh

# extract files
tar -xf gtz_public_0.2.2h_ubuntu_pre_release.tgz

# install gtz
mkdir -p $PREFIX/bin
cp -r ./gtz_public_0.2.2h_ubuntu_pre_release/_gtz $PREFIX/bin/gtz
