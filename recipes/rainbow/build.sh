#!/bin/bash

mkdir -p $PREFIX/bin

# The tarball has "._*" files (something macOS related?!),
# which also includes "._rainbow_$PKG_VERSION".
# conda-build may or may not hoist the folder, apparently.
# => Add a "|| true" so it is Ok to fail on the "cd".
cd rainbow_$PKG_VERSION || true

make CC="${CC}" CFLAGS="${CFLAGS}"

cp rainbow $PREFIX/bin

cp select_all_rbcontig.pl $PREFIX/bin
cp select_best_rbcontig.pl $PREFIX/bin
cp select_sec_rbcontig.pl $PREFIX/bin
cp select_best_rbcontig_plus_read1.pl $PREFIX/bin

chmod +x $PREFIX/bin/select_*

sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/select_*.pl
