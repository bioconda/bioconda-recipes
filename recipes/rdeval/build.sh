#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o xtrace

if [ -e "$PREFIX/include" ]; then
    export CPPFLAGS="${CPPFLAGS:+$CPPFLAGS }-I$PREFIX/include"
fi

if [ -e "$PREFIX/lib" ]; then
    export LDFLAGS="${LDFLAGS:+$LDFLAGS }-L$PREFIX/lib"
fi

echo "CPPFLAGS=\"$CPPFLAGS\""
echo "LDFLAGS=\"$LDFLAGS\""

cd "$SRC_DIR"

make -j "$CPU_COUNT"
install -d "$PREFIX/bin"
install -v -m 0755 build/bin/rdeval "$PREFIX/bin/"



# Compiling C++ programs
# n.o is made automatically from n.cc, n.cpp, or n.C with a recipe of the form ‘$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c’. We encourage you to use the suffix ‘.cc’ or ‘.cpp’ for C++ source files instead of ‘.C’ to better support case-insensitive file systems.
