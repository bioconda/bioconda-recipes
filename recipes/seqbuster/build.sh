#!/bin/bash
set -eu -o pipefail
target=$PREFIX/share/java/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $target
mkdir -p $PREFIX/bin
cp modules/miraligner/miraligner.jar $target/.
cp $RECIPE_DIR/miraligner.sh $target/miraligner
ln -s $target/miraligner $PREFIX/bin


