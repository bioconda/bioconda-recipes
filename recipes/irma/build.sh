#!/bin/sh
set -e

mkdir -p $PREFIX/bin
mv $SRC_DIR/* $PREFIX/bin/

# remove unnecessary files and binaries for programs that should be installed with conda
rm $PREFIX/bin/IRMA_RES/third_party/packaged-citations-licenses/blat-*
rm $PREFIX/bin/IRMA_RES/third_party/packaged-citations-licenses/gnu-parallel-*
rm $PREFIX/bin/IRMA_RES/third_party/packaged-citations-licenses/minimap2-*
rm $PREFIX/bin/IRMA_RES/third_party/packaged-citations-licenses/pigz-*
rm $PREFIX/bin/IRMA_RES/third_party/packaged-citations-licenses/samtools-*

rm $PREFIX/bin/IRMA_RES/third_party/blat_*
rm $PREFIX/bin/IRMA_RES/third_party/parallel
rm $PREFIX/bin/IRMA_RES/third_party/minimap2_*
rm $PREFIX/bin/IRMA_RES/third_party/pigz_*
rm $PREFIX/bin/IRMA_RES/third_party/samtools_*

rm $PREFIX/bin/LABEL_RES/third_party/parallel
rm $PREFIX/bin/LABEL_RES/third_party/copyright_and_licenses/gnu-parallel-*