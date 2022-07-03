#!/bin/sh
set -e

mkdir -p $PREFIX/bin
mv $SRC_DIR/* $PREFIX/bin/

# remove unnecessary files and binaries for programs that should be installed with conda
rm -rf $PREFIX/bin/IRMA_RES/scripts/packaged-citations-licenses
rm $PREFIX/bin/IRMA_RES/scripts/parallel
rm $PREFIX/bin/IRMA_RES/scripts/blat_*
rm $PREFIX/bin/IRMA_RES/scripts/minimap2_*
rm $PREFIX/bin/IRMA_RES/scripts/pigz_*
rm $PREFIX/bin/IRMA_RES/scripts/samtools_*
rm -rf $PREFIX/bin/LABEL_RES/scripts/binaries_and_licenses/muscle*
rm -rf $PREFIX/bin/LABEL_RES/scripts/binaries_and_licenses/fasttree2.1.4
rm $PREFIX/bin/LABEL_RES/scripts/binaries_and_licenses/shogun1.1.0_cmdline_static/shogun_linux32
rm $PREFIX/bin/LABEL_RES/scripts/FastTreeMP*
rm $PREFIX/bin/LABEL_RES/scripts/muscle*
rm $PREFIX/bin/LABEL_RES/scripts/shogun_Linux32
