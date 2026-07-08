#!/bin/bash
set -euo pipefail

# XGB_PREFIX points the Makefile at the build env's include/ and lib/ for
# libxgboost. The Makefile bakes -Wl,-rpath,$XGB_PREFIX/lib; conda-build's
# post-processing relocates that to an $ORIGIN-relative RPATH, so the installed
# binary finds libxgboost.so without activating any env.
make CC="${CC}" XGB_PREFIX="${PREFIX}"

install -Dm755 methscope "${PREFIX}/bin/methscope"
