#!/bin/bash

mkdir -p "${PREFIX}/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# Compile purge_dups
cd src
make CC="${CC}" -j"${CPU_COUNT}"
cd ../bin

install -v -m 0755 calcuts get_seqs ngscstat pbcstat purge_dups split_fa "${PREFIX}/bin"
# Copy scripts
cp -rf ../scripts/* "${PREFIX}/bin"
