#!/bin/bash
outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin
cp -R {bin,database,example,galaxy,lib,LICENSE} ${outdir}/
#Set up links for 
for f in ${outdir}/bin/*; do
    ln -s ${f} ${PREFIX}/bin
    fbname=$(basename "$f")
done

#Activate/Deactivate dir
ACTIVATE_DIR=$PREFIX/etc/conda/activate.d
DEACTIVATE_DIR=$PREFIX/etc/conda/deactivate.d
mkdir -p $ACTIVATE_DIR
mkdir -p $DEACTIVATE_DIR
cp $RECIPE_DIR/scripts/activate.sh $ACTIVATE_DIR/ngsplot-activate.sh
cp $RECIPE_DIR/scripts/deactivate.sh $DEACTIVATE_DIR/ngsplot-deactivate.sh