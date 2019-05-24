#!/bin/bash
set -eoux pipefail
mkdir -p ${PREFIX}/bin

# Annoyingly, this requires an unreleased version of marginPhase
git clone https://github.com/benedictpaten/marginPhase.git
pushd marginPhase
git checkout a58020d2e15d599625b5a41580ca2f609d967421
git submodule update --init
mkdir build
pushd build
cmake ..
make
cp marginPhase ${PREFIX}/bin/
popd
popd


mkdir build
pushd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
make install
