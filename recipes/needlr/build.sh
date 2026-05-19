#!/bin/bash
set -eu -o pipefail

refloc=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $refloc
mkdir -p $PREFIX/bin

cd $SRC_DIR

cp needLR $PREFIX/bin/
cp -r src/ $PREFIX/bin/
cp -r backend_files/* $refloc/
cp -r examples/ $refloc/

chmod +x $PREFIX/bin/needLR



sed -i "s?REFLOCPATH?$refloc?g" $PREFIX/bin/needLR

#temporary shebang fix
srcfiles=( $(ls $PREFIX/bin/src/*.awk) )
for file in ${srcfiles[@]}
do
    sed -i 's?/bin/awk -f?/usr/bin/env -S awk -f?g' $file
done
