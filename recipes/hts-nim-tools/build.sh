#!/bin/bash
set -eu -o pipefail

# Build script based off of mosdepth build
# https://github.com/brentp/mosdepth/blob/master/scripts/install.sh

NIM_VERSION=v0.18.0
NIMBLE_VERSION=v0.8.10
export base=$(pwd)

# Install nim
git clone -b $NIM_VERSION --depth 1 git://github.com/nim-lang/nim nim-$NIM_VERSION/
cd nim-$NIM_VERSION
git clone -b $NIM_VERSION --depth 1 git://github.com/nim-lang/csources csources/

cd csources
# Fix compiler references to use conda set CC
export LINKER=$CC
sed -i.bak '/^CC=/s/^/#/g' build.sh
sed -i.bak '/^LINKER=/s/^/#/g' build.sh
sh build.sh
cd ..
rm -rf csources
bin/nim c koch
./koch boot -d:release

export PATH=$base/nim-$NIM_VERSION/bin/:$PATH:$base/nimble/src:$PATH

cd $base
echo $PATH

set -x

git clone -b $NIMBLE_VERSION --depth 1 git://github.com/nim-lang/nimble.git
cd nimble
nim c src/nimble

cd $base
git clone --depth 1 git://github.com/brentp/hts-nim.git
cd hts-nim
grep -v requires hts.nimble > k.nimble && mv k.nimble hts.nimble
nimble install -y

echo $(which nimble)
echo $(pwd)

set -x
cd $base
nimble --nimbleDir:$base/.nimble install -y

mkdir -p $PREFIX/bin
chmod a+x hts_nim_tools
cp hts_nim_tools $PREFIX/bin
