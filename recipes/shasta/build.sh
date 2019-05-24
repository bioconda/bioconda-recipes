#!/bin/bash
set -eoux pipefail

# Annoyingly, this requires an unreleased version of marginPhase
git clone https://github.com/benedictpaten/marginPhase.git
pushd marginPhase
git checkout a58020d2e15d599625b5a41580ca2f609d967421
git submodule update --init
popd


mkdir build
pushd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
make MarginCore
make install
