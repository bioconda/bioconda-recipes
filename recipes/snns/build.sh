#!/bin/bash
set -eu -o pipefail

# In principle we should be able to build this from source,
# possiblly deliberatly using our verion of flex to first
# regenerate the parsers using something like this:
#
# $ touch kernel/sources/*.l tools/sources/*.l
# $ ./configure --enable-global --prefix $PREFIX
# $ make install
#
# I failed to get this to work, so have compromised with
# using the provided pre-compiled 64 bit linux binaries.

mkdir -p $PREFIX/bin

# Use the precompiled tool binaries
cp tools/bin/x86_64-pc-unknown-linux-gnuoldld/* $PREFIX/bin/

# Use the precompiled GUI binary
mv xgui/bin/x86_64-pc-unknown-linux-gnuoldld/xgui $PREFIX/bin/

# Readme.install suggests creating symlink snns to xgui
ln -s $PREFIX/bin/xgui $PREFIX/bin/snns
