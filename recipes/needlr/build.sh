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


# if there is no terminal then don't attempt fancy printing
sed -i "s?REFLOCPATH?$refloc?g" $PREFIX/bin/needLR
if [[ -z ${TERM+x} ]]
then
    sed -i 's/bold=$(tput bold)/bold=""/g' $PREFIX/bin/needLR
    sed -i 's/normal=$(tput normal)/normal=""/g' $PREFIX/bin/needLR
fi