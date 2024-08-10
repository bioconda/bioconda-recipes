#!/usr/bin/env bash

set -xe

mkdir -p $PREFIX/bin 
cp STITCH.R $PREFIX/bin

# patch a Git submodule
pushd src/SeqLib/
patch -p1 < ${RECIPE_DIR}/seqlib-aarch64.patch
popd
    
$R CMD INSTALL --build --install-tests .
