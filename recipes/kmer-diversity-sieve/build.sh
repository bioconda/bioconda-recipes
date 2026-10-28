#!/bin/bash
set -euo pipefail

# The Makefile hard-sets CFLAGS to include -march=native (or -mcpu=native on arm64),
# which tunes the binary to the build machine. A command-line assignment overrides it.
make serial CC="${CC}" CFLAGS="${CFLAGS} -O3 -D_FILE_OFFSET_BITS=64" LDLIBS="${LDFLAGS} -lm"

mkdir -p "${PREFIX}/bin"
install -v -m 0755 l1_pipeline_serial "${PREFIX}/bin"
