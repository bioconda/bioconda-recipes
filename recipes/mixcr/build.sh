#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/share
cp -f mixcr.jar $PREFIX/share/mixcr-$PKG_VERSION-$PKG_BUILDNUM.jar
sed "190i\
jar=\"/opt/anaconda1anaconda2anaconda3share/mixcr-$PKG_VERSION-$PKG_BUILDNUM.jar\"" mixcr > $PREFIX/bin/mixcr
chmod +x $PREFIX/bin/mixcr
