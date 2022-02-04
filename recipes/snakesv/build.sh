#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/opt/snakeSV/

# Full path to the Snakefile
sed -i "s|workflow/Snakefile|$PREFIX/opt/snakeSV/workflow/Snakefile|g" snakeSV

cp -r * $PREFIX/opt/snakeSV/
ln -s $PREFIX/opt/snakeSV/snakeSV $PREFIX/bin/
ln -s $PREFIX/opt/snakeSV/example/aj_trio/01_prepare_short_read.sh $PREFIX/bin/
ln -s $PREFIX/opt/snakeSV/example/aj_trio/02_download_gtf_annotation.sh $PREFIX/bin/
ln -s $PREFIX/opt/snakeSV/example/aj_trio/03_prepare_long_read.sh $PREFIX/bin/
ln -s $PREFIX/opt/snakeSV/example/aj_trio/04_download_custom_annotation.sh $PREFIX/bin/

