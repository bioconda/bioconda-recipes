#!/bin/bash
mkdir -p ${PREFIX}/bin

chmod +x $SRC_DIR/bin/*

mv $SRC_DIR/bin/snippy $PREFIX/bin
mv $SRC_DIR/bin/snippy-core $PREFIX/bin
mv $SRC_DIR/bin/snippy-make_tarball $PREFIX/bin
mv $SRC_DIR/bin/snippy-vcf_filter $PREFIX/bin
mv $SRC_DIR/bin/snippy-vcf_report $PREFIX/bin
mv $SRC_DIR/bin/snippy-vcf_to_tab $PREFIX/bin
echo "Snippy files in the bin directory should be picked up by conda."