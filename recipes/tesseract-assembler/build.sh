#!/usr/bin/env bash
set -euo pipefail

make -j"${CPU_COUNT:-4}" CXX="${CXX:-g++}"
# Since 1.6.1 the project defines its install layout once, in `make install`: the user command
# `tesseract` in bin/, its engine and model fetcher (with the fetcher's checksum list) in
# libexec/tesseract/, and the organism-detection sketch in share/tesseract/.
make install PREFIX="${PREFIX}"
