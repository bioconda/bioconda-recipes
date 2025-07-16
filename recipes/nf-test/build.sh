#!/bin/bash

BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $PREFIX/bin
mkdir -p $PACKAGE_HOME

sed -i "s|APP_HOME=.*|APP_HOME=\"${PACKAGE_HOME}\"|g" nf-test

cp nf-test* $PACKAGE_HOME

chmod +x $PACKAGE_HOME/nf-test

ln -s $PACKAGE_HOME/nf-test $PREFIX/bin/nf-test