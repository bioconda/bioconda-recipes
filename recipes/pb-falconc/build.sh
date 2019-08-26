#!/bin/bash
set -vexu -o pipefail

NIM_VERSION=devel
# devel, b/c branches are missing.
NIM_VERSION=v0.20.2
#NIMBLE_VERSION=v0.9.0
export base=$(pwd)

# Install nim
git clone -b $NIM_VERSION --depth 1 git://github.com/nim-lang/nim nim-$NIM_VERSION/
pushd nim-$NIM_VERSION

export PATH=$base/nim-$NIM_VERSION/bin:$PATH
mkdir -p $base/nim-$NIM_VERSION/bin

# Fix compiler references to use conda set CC
export LINKER=$CC

git clone --depth 1 https://github.com/nim-lang/csources.git
pushd csources
sed -i.bak '/^CC=/s/^/#/g' build.sh
sed -i.bak '/^LINKER=/s/^/#/g' build.sh
sh build.sh
popd

bin/nim c --skipUserCfg --skipParentCfg --gcc.exe:$CC --gcc.linkerexe:$CC koch
./koch boot --gcc.exe:$CC --gcc.linkerexe:$CC -d:release
./koch tools --gcc.exe:$CC --gcc.linkerexe:$CC # Compile Nimble and other tools.

export PATH=$base/nim-$NIM_VERSION/bin/:$PATH:$base/nimble/src:$PATH

popd

export NIMBLEDIR=$(pwd)/.nimble
make build
make install
