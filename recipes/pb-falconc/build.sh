#!/bin/bash
set -vexu -o pipefail

NIM_VERSION=devel
# devel, b/c branches are missing.
#NIM_VERSION=v0.20.2
#NIMBLE_VERSION=v0.9.0
export base=$(pwd)

# Install nim
git clone -b $NIM_VERSION --depth 1 git://github.com/nim-lang/nim nim-$NIM_VERSION/
cd nim-$NIM_VERSION
git clone                 --depth 1 git://github.com/nim-lang/csources csources/

cd csources
# Fix compiler references to use conda set CC
# https://github.com/brentp/mosdepth/blob/master/scripts/install.sh
export LINKER=$CC
# But CircleCI does not find "gcc", so I will comment those 2 sed lines out. ~cd
#sed -i.bak '/^CC=/s/^/#/g' build.sh
#sed -i.bak '/^LINKER=/s/^/#/g' build.sh
sh build.sh
cd ..
rm -rf csources
bin/nim c koch
./koch boot -d:release

export PATH=$base/nim-$NIM_VERSION/bin:$PATH

#git clone -b $NIMBLE_VERSION --depth 1 git://github.com/nim-lang/nimble.git
#cd nimble
#nim c src/nimble

which nim
nim -v

cd $base
ls -larth

cd $base

export NIMBLEDIR=$(pwd)/.nimble
#nimble install -y
make build

#mkdir -p $PREFIX/bin
#chmod a+x falconc
#cp falconc $PREFIX/bin
ls -larth src
make install
