#!/bin/bash
set -euo pipefail

# ONEview is not built here: the fastga package already provides it, and two
# packages installing the same file would conflict.
make CC="${CC}" CFLAGS="${CFLAGS} -O3" LIBS="${LDFLAGS} -lpthread -lz" \
  tanbed gdbmask svfind taco

mkdir -p "${PREFIX}/bin"
install -m 755 tanbed gdbmask svfind taco "${PREFIX}/bin/"
