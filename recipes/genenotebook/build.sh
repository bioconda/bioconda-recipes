#!/bin/bash

mkdir -p $PREFIX/bin/.genenotebook
cp -r * $PREFIX/bin/.genenotebook
ln -s $PREFIX/bin/genenotebook/genenotebook ${PREFIX}/bin
