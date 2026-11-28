#!/bin/bash
set -euxo pipefail

# Kplex: a single C file that drives FastK and Histex (from the fastk package) for every k. Installed outside bin/:
# on a case-insensitive file system (macOS) bin/Kplex and the kplex entry point would be the same file.
mkdir -p "${PREFIX}/libexec/kplexity"
${CC} ${CFLAGS} ${CPPFLAGS} -O3 -Wall -fno-strict-aliasing -o "${PREFIX}/libexec/kplexity/Kplex" FASTK/Kplex.c ${LDFLAGS} -lm

# the kplex Python package and CLI
${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv
