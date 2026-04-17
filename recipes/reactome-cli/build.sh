#!/bin/bash
TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv reactome*.jar $TGT/reactome-cli.jar

cp $RECIPE_DIR/reactome.sh $TGT/reactome
ln -s $TGT/reactome $PREFIX/bin
chmod 0755 "${PREFIX}/bin/reactome"