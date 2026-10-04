#!/bin/bash

# rename jar
mv $SRC_DIR/metexplore2sbml-*.jar $SRC_DIR/metexplore2sbml.jar
chmod 0755 "${SRC_DIR}/metexplore2sbml.jar"

# copy jar file and wrapper script to $PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
# add a sym link to $PREFIX/bin

OUTDIR=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $OUTDIR
mkdir -p $PREFIX/bin

cp -Rf * $OUTDIR/
cp -f $RECIPE_DIR/metexplore2sbml.sh $OUTDIR/metexplore2sbml

ln -sf $OUTDIR/metexplore2sbml $PREFIX/bin
chmod 0755 "${PREFIX}/bin/metexplore2sbml"
