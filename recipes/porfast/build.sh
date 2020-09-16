#!/bin/sh

set -euxo pipefail

if [[ $OSTYPE == "darwin"* ]]; then
  export HOME="/Users/distiller"
  mv bin/porfast_osx $PREFIX/bin/porfast
  chmod +f $PREFIX/bin/porfast
else
  mkdir -p $PREFIX/bin
  nimble install -y --verbose argparse
  nim c --threads:on -p:lib --opt:speed -o:$PREFIX/bin/porfast src/porfast.nim
fi

#pushd nim_source
#if [[ $OSTYPE == "darwin"* ]]; then
#  export HOME="/Users/distiller"
#  bash build.sh --os darwin --cpu x86_64
#else
#  bash build.sh --os linux --cpu x86_64
#fi
#bname=`basename $CC`
#echo "gcc.exe = \"${bname}\"" >> config/nim.cfg
#echo "gcc.linkerexe = \"${bname}\"" >> config/nim.cfg
#echo "clang.exe = \"${bname}\"" >> config/nim.cfg
#echo "clang.linkerexe = \"${bname}\"" >> config/nim.cfg
#bin/nim c  koch
#./koch tools
#popd
