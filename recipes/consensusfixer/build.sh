#!/usr/bin/env bash

set -eu -o pipefail

consensusfixer="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
mkdir -p $consensusfixer
mkdir -p $PREFIX/bin

cp ConsensusFixer.jar $consensusfixer/ConsensusFixer.jar
cp $RECIPE_DIR/ConsensusFixer.sh $consensusfixer/ConsensusFixer
ln -s $consensusfixer/ConsensusFixer $PREFIX/bin
chmod +x "${PREFIX}/bin/ConsensusFixer"
