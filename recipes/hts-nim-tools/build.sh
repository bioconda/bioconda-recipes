#!/bin/bash
set -eu -o pipefail

# Build script based off of mosdepth build
# https://github.com/brentp/mosdepth/blob/master/scripts/install.sh

# c2nim needs development branch of nim, see notes below
export BRANCH=devel
export base=$(pwd)

# Install nim
git clone -b $BRANCH --depth 1 git://github.com/nim-lang/nim nim-$BRANCH/
cd nim-$BRANCH
git clone --depth 1 git://github.com/nim-lang/csources csources/
cd csources
sh build.sh
cd ..
rm -rf csources
bin/nim c koch
./koch boot -d:release

# Nimble package manager
./koch nimble
./bin/nimble refresh --nimbleDir:$base/.nimble
export PATH=$base/nim-$BRANCH/bin:$PATH

# Avoid c2nim build errors: https://github.com/nim-lang/c2nim/issues/115
# Need to build this from within the nim-devel folder for some unknown reason
./bin/nimble install --nimbleDir:$base/.nimble -y compiler@#head

cd $base
echo $PATH

set -x

echo $(which nimble)
echo $(pwd)

if [ ! -x hts-nim ]; then
    cd $base
    git clone --depth 1 https://github.com/brentp/hts-nim/
    cd hts-nim 
    # Avoid c2nim build errors: https://github.com/nim-lang/c2nim/issues/115
    nimble install --nimbleDir:$base/.nimble -y c2nim@#head
    nimble --nimbleDir:$base/.nimble install -y
fi

set -x
cd $base
nimble --nimbleDir:$base/.nimble install -y

mkdir -p $PREFIX/bin
chmod a+x hts_nim_tools
cp hts_nim_tools $PREFIX/bin
