#!/bin/bash
set -eu -o pipefail

refloc=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $refloc
mkdir -p $PREFIX/bin

cd $SRC_DIR

cp needLR $PREFIX/bin/
cp -r src/ $PREFIX/bin/
cp -r backend_files/* $refloc/
chmod +x $PREFIX/bin/needLR



sed -i "s?REFLOCPATH?$refloc?g" $PREFIX/bin/needLR

#temporarily remove fancy printing
#sed -i 's/normal=$(tput normal)/normal=""/g' $PREFIX/bin/needLR
