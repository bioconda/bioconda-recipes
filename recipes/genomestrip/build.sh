#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

echo "PREFIX=${PREFIX}"
echo "TGT=${TGT}"

cd "${SRC_DIR}"
cp -rvp LICENSE.txt README.txt THIRDPARTY.txt lib conf R qscript "${TGT}"

cp $RECIPE_DIR/genomestrip.sh $TGT/genomestrip
ln -s $TGT/genomestrip $PREFIX/bin
chmod 0755 "${PREFIX}/bin/genomestrip"
