#!/usr/bin/env bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# Skip copying of bwa, minimap2, and samtools
sed -i.bak \
    -e "s| bwa samtools minimap2||g" \
    Makefile

# Use conda's gcc and includes, also skip build of bwa, minimap2, and samtools
sed -i.bak \
    -e "s| bwa_ samtools_ minimap2_||g" \
    -e "s|gcc|$CC|g" \
    -e "s|-lz|-lz -isystem ${PREFIX}/include|g" \
    util/Makefile

# Add version info (original required internet connection)
sed -i.bak "s=BIOCONDA_SED_REPLACE=$PKG_VERSION=" lib/kit.py

# Create share directory
SHARE_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
mkdir -p ${SHARE_DIR}/
cp -rf ./lib ${SHARE_DIR}/

# Build
make CC="${CC}" CFLAGS="-O3" LDFLAGS="${LDFLAGS}" -j "${CPU_COUNT}"
mkdir -p ${PREFIX}/bin
cp -f bin/* ${PREFIX}/bin

# fix hardcoded path
sed -i.bak "s=BIOCONDA_SED_REPLACE=$SHARE_DIR=" nextPolish
chmod 755 nextPolish
cp -f nextPolish ${PREFIX}/bin
