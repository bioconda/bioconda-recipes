#!/bin/bash
SHARE=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $PREFIX/config
sed "s|^path = .*$|path = $PREFIX/bin|g" $SHARE/config.ini.default > $PREFIX/config/config.ini
