#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/opt/panpasco/


sed -i "s|\${BASH_SOURCE%/\*}|$PREFIX/opt/panpasco|g" panpasco-pipeline
sed -i "s|\${BASH_SOURCE%/\*}|$PREFIX/opt/panpasco|g" panpasco-distance

cp -r panpasco-pipeline panpasco-distance scripts alignment_pipeline.Snakefile *.R distance.Snakefile Trimmomatic_adapter configfile* $PREFIX/opt/panpasco
ln -s $PREFIX/opt/panpasco/panpasco-pipeline $PREFIX/bin
ln -s $PREFIX/opt/panpasco/panpasco-distance $PREFIX/bin
