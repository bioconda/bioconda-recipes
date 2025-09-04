#!/bin/bash
export NCBI_OUTDIR=$SRC_DIR/ncbi-outdir

pushd ngs-sdk
./configure \
    --prefix="${PREFIX}" \
    --build-prefix="${NCBI_OUTDIR}" \
    --debug
make -j"${CPU_COUNT}"
make install
make test
popd
