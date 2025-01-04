#!/bin/bash

set -exo pipefail

readonly PROGRAMS=(
    qTMclust
    USalign
    TMalign
    TMscore
    MMalign
    se
    pdb2xyz
    xyz_sfetch
    pdb2fasta
    pdb2ss
    NWalign
    HwRMSD
    cif2pdb
    pdbAtomName
    addChainID
)

CXXFLAGS="-static -static-libgcc -static-libstdc++"
LDFLAGS="-static -lm"
CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}"

if [[ $(uname) == Linux ]]; then
    make -j${CPU_COUNT} CC="${CXX}" CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}"
elif [[ $(uname) == Darwin ]]; then
    make -j${CPU_COUNT} CC="${CXX}" LDFLAGS="-lm"
fi

install -d "${PREFIX}/bin"
install -m 755 "${PROGRAMS[@]}" "${PREFIX}/bin/"
