#!/bin/bash
STAGING=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG-BUILDNUM
mkdir -p $STAGING
wget -O- -q http://bioconductor.org/packages/3.5/data/annotation/src/contrib/TxDb.Hsapiens.UCSC.hg38.knownGene_3.4.0.tar.gz > $STAGING/pkg.tar.gz
R CMD INSTALL --build $STAGING/pkg.tar.gz
rm $STAGING/pkg.tar.gz
