#!/bin/bash
 
# $PYTHON -m pip install . -vv
 
mkdir -p $PREFIX/bin/
 
cp $RECIPE_DIR/../CAMPneu.nf $RECIPE_DIR/../nextflow.config $PREFIX/bin/

chmod +x $PREFIX/bin/CAMPneu.nf $PREFIX/bin/nextflow.config
