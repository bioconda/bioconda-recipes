#!/bin/bash

set -x

# create target directory
MZMINEDIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $MZMINEDIR

cp -r bin $MZMINEDIR/
cp -r lib $MZMINEDIR/

mkdir -p $PREFIX/bin

ln -fs $MZMINEDIR/bin/MZmine $PREFIX/bin/MZmine
ln -fs $MZMINEDIR/bin/MZmine $PREFIX/bin/mzmine
