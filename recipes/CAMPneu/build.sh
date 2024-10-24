#!/bin/bash
 
# $PYTHON -m pip install . -vv
 
mkdir -p $PREFIX/bin/
 
cp CAMPneu.nf nextflow.config $PREFIX/bin/

chmod +x $PREFIX/bin/CAMPneu.nf $PREFIX/bin/nextflow.config
