#!/bin/bash

mkdir -p "${PREFIX}/bin"

mkdir build
pushd build
cmake ..
make

cp bin/bam-readcount "${PREFIX}/bin"
popd
