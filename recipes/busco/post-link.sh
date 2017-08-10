#!/bin/bash
SHARE=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $PREFIX/config
sed -i.bak "s|^path = .*$|path = $PREFIX/bin|g" > $PREFIX/config/config.ini
