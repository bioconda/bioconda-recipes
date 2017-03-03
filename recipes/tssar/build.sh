#!/bin/bash
cp $RECIPE_DIR/R_lib_install $SRC_DIR/

$R CMD BATCH --no-save --no-restore R_lib_install

mkdir -p $PREFIX/bin

cp TSSAR $PREFIX/bin

chmod +x $PREFIX/bin/TSSAR
