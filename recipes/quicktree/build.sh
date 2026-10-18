#!/bin/bash

set -eux
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "$PREFIX"/{bin,lib,include/quicktree}

make CC="${CC}" -j"${CPU_COUNT}"

install -v -m 0755 quicktree $PREFIX/bin
install -v -m 0644 libquicktree.so "${PREFIX}/lib"
# some header files are named generic enough to warrant namespacing
install -v -m 0755 include/*.h "${PREFIX}/include/quicktree"
