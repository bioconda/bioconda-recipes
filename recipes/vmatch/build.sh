#!/bin/bash
set -euxo pipefail

# Those variables are also used in pre and post-link scripts
BIN_DIR="$PREFIX"/bin
SHARE_DIR="$PREFIX"/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
DOC_DIR="$SHARE_DIR"/doc
export CFLAGS="${CFLAGS} -O3 -Wno-format-overflow"

# Create directories
mkdir -p ${BIN_DIR}
mkdir -p ${SHARE_DIR}
mkdir -p ${DOC_DIR}
mkdir -p ${PREFIX}/lib

sed -i.bak 's|-O3 -g|-O3 -g -Wno-format-overflow -Wno-deprecated-declarations|' SELECT/makefile
rm -f SELECT/*.bak

install -v -m 0755 *.pl *.sh "${BIN_DIR}"
install -v -m 0755 chain2dim matchcluster mkdna6idx mkvtree vendian \
    vmatch vmatchselect vseqinfo vseqselect vstree2tex vsubseqselect "${BIN_DIR}"

# Compile selection functions and install them.
# The SYSTEM variable is not really needed
# but we set it as should be done.
# The libs are installed in ${PREFIX}/lib so `vmatch`
# can find them without the full path
# (thanks to rpath modification by conda).
pushd SELECT
SYSTEM=$(uname -s) make CC="${CC}" -j"${CPU_COUNT}"
cp -pf *.so ${PREFIX}/lib
popd

# Copy data, doc and various files
cp -rf TRANS ${SHARE_DIR}
cp -f *.pdf ${DOC_DIR}
cp -f LICENSE README.distrib CHANGELOG ${SHARE_DIR}
