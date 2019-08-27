#!/bin/bash
set -vexu -o pipefail

export base=$(pwd)

pushd nim
./build.sh
bin/nim c --gcc.exe:$CC --gcc.linkerexe:$CC koch
./koch tools --gcc.exe:$CC --gcc.linkerexe:$CC
popd

export PATH=$base/nim/bin:$PATH

make build
make install
