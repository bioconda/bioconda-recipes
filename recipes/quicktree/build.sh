#!/bin/bash

set -eux

mkdir -p "$PREFIX"/{bin,lib,include/quicktree}

make CC=$CC

cp quicktree $PREFIX/bin
cp libquicktree.so "${PREFIX}/lib/"
# some header files are named generic enough to warrant namespacing
cp include/*.h "${PREFIX}/include/quicktree/"
