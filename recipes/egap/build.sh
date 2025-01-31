#!/usr/bin/env bash
set -euxo pipefail

# Ensure we pass the correct compiler and library flags to purge_dups
export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

# 1) Build 'purge_dups'
git clone https://github.com/dfguan/purge_dups.git
cd purge_dups/src
make CC="$CC" \
     CFLAGS="$CFLAGS $CPPFLAGS" \
     LDFLAGS="$LDFLAGS"
mkdir -p "$PREFIX/bin"
cp ../bin/* "$PREFIX/bin/"
cd "$SRC_DIR"

# 2) Build 'Ratatosk'
git clone --recursive https://github.com/DecodeGenetics/Ratatosk.git
cd Ratatosk
mkdir -p build && cd build
cmake -DCMAKE_INSTALL_PREFIX="$PREFIX" ..
make
make install
cd "$SRC_DIR"

# 3) Install or copy EGAP main script
chmod +x EGAP.py
mkdir -p "$PREFIX/bin"
cp EGAP.py "$PREFIX/bin/EGAP"
