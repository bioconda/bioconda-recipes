#!/bin/bash

set -xe

FACETS_GIT_REF=`grep -P ' *^FACETS_REF' install/install_pkgs.R \
| sed 's/ //g; s/<-//; s/=//;' \
| tr "'" '"' \
| sed 's/FACETS_REF"//; s/".*//'`

mkdir -p $PREFIX/bin
chmod a+x bin/cnv_facets.R
cp bin/cnv_facets.R $PREFIX/bin/

cnv_facets.R -d 1 8000 \
    -t test/data/TCRBOA6-T-WEX.sample.bam \
    -n test/data/TCRBOA6-N-WEX.sample.bam \
    -vcf test/data/common.sample.vcf.gz \
    -o test_out/out
