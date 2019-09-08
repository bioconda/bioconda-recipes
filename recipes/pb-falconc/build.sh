#!/bin/bash
set -vexu -o pipefail

export base=$(pwd)

pushd nim
# inject compilers
echo "gcc.exe = \"$CC\"" >> config/nim.cfg
echo "gcc.linkerexe = \"$CC\"" >> config/nim.cfg
echo "clang.exe = \"$CC\"" >> config/nim.cfg
echo "clang.linkerexe = \"$CC\"" >> config/nim.cfg
./build.sh
bin/nim c koch
./koch tools
popd

export PATH=$base/nim/bin:$PATH
make build
make install
