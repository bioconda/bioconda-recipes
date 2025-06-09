#!/bin/bash

# workaround 'should_not_use_fn'
mv $SRC_DIR/download $SRC_DIR/met4j-toolbox.jar
chmod 0755 "${SRC_DIR}/met4j-toolbox.jar"

# copy jar file and wrapper script to $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
# add a sym link to $PREFIX/bin

OUTDIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $OUTDIR
mkdir -p $PREFIX/bin

cp -Rf * $OUTDIR/
cp -f $RECIPE_DIR/met4j.sh $OUTDIR/met4j

ln -sf $OUTDIR/met4j $PREFIX/bin
chmod 0755 "${PREFIX}/bin/met4j"
