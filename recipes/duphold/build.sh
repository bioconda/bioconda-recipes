#!/bin/bash
set -eu -o pipefail

# Compile nim
pushd nim_source
bash build.sh --os linux --cpu x86_64
bname=`basename $CC`
echo "gcc.exe = \"${bname}\"" >> config/nim.cfg
echo "gcc.linkerexe = \"${bname}\"" >> config/nim.cfg
bin/nim c  koch #--gcc.exe=$CC --gcc.linkerexe=$CC koch 
./koch tools #--gcc.exe=$CC --gcc.linkerexe=$CC
popd

export PATH=$SRC_DIR/nim_source/bin:$PATH

# the actual recipe
mkdir -p $PREFIX/bin
nimble install -y --verbose
mv duphold ${PREFIX}/bin
