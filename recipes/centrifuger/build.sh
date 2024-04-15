#!/bin/bash
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

mkdir -p $PREFIX/bin

make CXX=$CXX RELEASE_FLAGS="$CXXFLAGS"
chmod +x centrifuger-download
chmod +x centrifuger-kreport
chmod +x centrifuger-inspect

cp {centrifuger,centrifuger-build,centrifuger-download,centrifuger-kreport,centrifuger-inspect} $PREFIX/bin
