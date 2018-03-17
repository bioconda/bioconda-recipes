#!/bin/bash

set -eu -o pipefail

indelfixer="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
mkdir -p $indelfixer
mkdir -p $PREFIX/bin

cp InDelFixer.jar $indelfixer/InDelFixer.jar
cp $RECIPE_DIR/InDelFixer.sh $indelfixer/InDelFixer
ln -s $indelfixer/InDelFixer $PREFIX/bin
chmod +x "${PREFIX}/bin/InDelFixer"
