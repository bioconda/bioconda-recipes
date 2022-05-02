#!/bin/bash
set -x
mkdir -p ${PREFIX}/bin

# Copy files
chmod 775 kSNP${PKG_VERSION}_Linux_package/kSNP3/*
rm kSNP${PKG_VERSION}_Linux_package/kSNP3/.DS_Store
cp kSNP${PKG_VERSION}_Linux_package/kSNP3/* ${PREFIX}/bin

# Fix hard coded paths
sed -i 's=/bin/tcsh=/usr/bin/env tcsh=' ${PREFIX}/bin/kSNP3
sed -i 's=/usr/local/kSNP3=$(which kSNP3)=' ${PREFIX}/bin/kSNP3
sed -i 's=/bin/tcsh=/usr/bin/env tcsh=' ${PREFIX}/bin/select_node_annotations3
sed -i 's=/bin/tcsh=/usr/bin/env tcsh=' ${PREFIX}/bin/extract_nth_locus3

# Debug
head ${PREFIX}/bin/kSNP3
head ${PREFIX}/bin/select_node_annotations3
head ${PREFIX}/bin/extract_nth_locus3
