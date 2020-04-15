#!/bin/bash
mkdir -p $PREFIX/bin
cp SNPsplit $PREFIX/bin
cp SNPsplit_genome_preparation $PREFIX/bin
cp tag2sort $PREFIX/bin

chmod a+x $PREFIX/bin/SNPsplit
chmod a+x $PREFIX/bin/SNPsplit_genome_preparation
chmod a+x $PREFIX/bin/tag2sort
