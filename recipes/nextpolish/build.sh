#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

mkdir -p "${PREFIX}/bin"

# Create share directory
SHARE_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
mkdir -p "${SHARE_DIR}"

cd source

if [[ "$(uname -s)" == "Darwin" ]]; then
	sed -i.bak "s|#include<malloc.h>||" lib/seqlist.h
fi

sed -i.bak "s|-O2|-O3|g" lib/htslib/Makefile
sed -i.bak "s|gcc|${CC}|" lib/htslib/Makefile
sed -i.bak "s|= ar|= ${AR}|" lib/htslib/Makefile
rm -f lib/htslib/*.bak

# Skip copying of bwa, minimap2, and samtools
sed -i.bak -e "s| bwa samtools minimap2||g" Makefile

# Use conda's gcc and includes, also skip build of bwa, minimap2, and samtools
sed -i.bak \
	-e "s| bwa_ samtools_ minimap2_||g" \
	-e "s|gcc|$CC|g" \
	-e "s|-lz|-L${PREFIX}/lib -lz -isystem ${PREFIX}/include|g" \
	util/Makefile

# Add version info (original required internet connection)
sed -i.bak "s|BIOCONDA_SED_REPLACE|${PKG_VERSION}|" lib/kit.py

rm -f util/*.bak
rm -f lib/*.bak

# Build
make CC="${CC}" AR="${AR}" LDFLAGS="${LDFLAGS}" -j1
make -C lib CC="${CC}" AR="${AR}" LDFLAGS="${LDFLAGS}" -j1

install -v -m 755 bin/* "${PREFIX}/bin"

rm -f lib/Makefile
rm -f lib/*.o
ls lib/
cp -rf ./lib ${SHARE_DIR}/

# fix hardcoded path
sed -i.bak "s|BIOCONDA_SED_REPLACE|${SHARE_DIR}|" nextPolish
rm -f *.bak

install -v -m 755 nextPolish "${PREFIX}/bin"
