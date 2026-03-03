#!/bin/bash
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
mkdir -p ~/.R
# plyranges no longer exports filter; use dplyr::filter for this call site.
sed -i '/importFrom(plyranges,filter)/d' NAMESPACE
sed -i 's/plyranges::filter/dplyr::filter/g' R/read_bam_insert_metrics.R

echo -e "CC=$CC
FC=$FC
CXX=$CXX
CXX98=$CXX
CXX11=$CXX
CXX14=$CXX" > ~/.R/Makevars
$R CMD INSTALL --build .
