#!/bin/bash
set -eu -o pipefail

make

mkdir -p ${PREFIX}/bin
cp hisat2 ${PREFIX}/bin
cp hisat2-align-l ${PREFIX}/bin
cp hisat2-align-s ${PREFIX}/bin
cp hisat2-build ${PREFIX}/bin
cp hisat2-build-l ${PREFIX}/bin
cp hisat2-build-new ${PREFIX}/bin
cp hisat2-build-s ${PREFIX}/bin
cp hisat2-inspect ${PREFIX}/bin
cp hisat2-inspect-l ${PREFIX}/bin
cp hisat2-inspect-s ${PREFIX}/bin
cp hisat2-repeat ${PREFIX}/bin
cp hisat2_extract_exons.py ${PREFIX}/bin
cp hisat2_extract_splice_sites.py ${PREFIX}/bin
cp hisat-3n ${PREFIX}/bin
cp hisat-3n-build ${PREFIX}/bin
cp hisat-3n-table ${PREFIX}/bin
