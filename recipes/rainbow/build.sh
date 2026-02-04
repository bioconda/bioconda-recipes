#!/bin/bash

export CFLAGS="${CFLAGS} -W -O3 -Wno-self-assign -Wno-unused-function"

mkdir -p "$PREFIX/bin"

# The tarball has "._*" files (something macOS related?!),
# which also includes "._rainbow_$PKG_VERSION".
# conda-build may or may not hoist the folder, apparently.
# => Add a "|| true" so it is Ok to fail on the "cd".
cd rainbow_$PKG_VERSION || true

sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' select_*.pl

make CC="${CC}" CFLAGS="${CFLAGS}"

install -v -m 0755 rainbow "$PREFIX/bin"
install -v -m 0755 *.pl "$PREFIX/bin"
