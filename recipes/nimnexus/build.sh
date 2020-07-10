#!/bin/bash
set -eu -o pipefail

# Build script based off of mosdepth build
# https://github.com/brentp/mosdepth/blob/master/scripts/install.sh

export base=$(pwd)

# Install nim
cd nim

cd csources
sh build.sh
cd ..
rm -rf csources
bin/nim c koch
./koch boot -d:release

export PATH=$base/nim/bin/:$PATH:$base/nimble/src:$PATH

cd $base
echo $PATH

set -x

cd nimble
nim c src/nimble

cd $base
cd hts-nim
grep -v requires hts.nimble > k.nimble && mv k.nimble hts.nimble
nimble install -y

echo $(which nimble)
echo $(pwd)

set -x
cd $base
nimble --nimbleDir:$base/.nimble install -y

mkdir -p $PREFIX/bin
chmod a+x nimnexus
cp nimnexus $PREFIX/bin
