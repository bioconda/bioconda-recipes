#!/usr/bin/env bash

# Create share directory
SHARE_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
mkdir -p ${SHARE_DIR}/
cp -r ./lib ${SHARE_DIR}/

# Skip copying of bwa, minimap2, and samtools
sed -i.backup \
    -e "s| bwa samtools minimap2||g" \
    Makefile

# Use conda's gcc and includes, also skip build of bwa, minimap2, and samtools
sed -i.backup \
    -e "s| bwa_ samtools_ minimap2_||g" \
    -e "s|gcc|$CC|g" \
    -e "s|-lz|-lz -isystem ${PREFIX}/include|g" \
    util/Makefile

# Add version info (original required internet connection)
sed -i.backup "s=BIOCONDA_SED_REPLACE=$PKG_VERSION=" lib/kit.py

# Build
make
mkdir -p ${PREFIX}/bin
cp bin/* ${PREFIX}/bin

# fix hardcoded path
sed -i "s=BIOCONDA_SED_REPLACE=$SHARE_DIR=" nextPolish
chmod 755 nextPolish
cp nextPolish ${PREFIX}/bin
