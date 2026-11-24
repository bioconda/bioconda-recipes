#!/bin/bash
set -euxo pipefail

# Kplex: a single C file that drives FastK and Histex (from the fastk package) for every k
mkdir -p "${PREFIX}/bin"
${CC} ${CFLAGS} ${CPPFLAGS} -O3 -Wall -fno-strict-aliasing -o "${PREFIX}/bin/Kplex" FASTK/Kplex.c ${LDFLAGS} -lm

# the kplex Python package and CLI
${PYTHON} -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv
