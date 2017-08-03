#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/share
cp -f mixcr.jar $PREFIX/share/mixcr-$PKG_VERSION-$PKG_BUILDNUM.jar
sed "s/jar\/mixcr.jar/share\/mixcr-$PKG_VERSION-$PKG_BUILDNUM.jar/g" mixcr > $PREFIX/bin/mixcr
chmod +x $PREFIX/bin/mixcr
