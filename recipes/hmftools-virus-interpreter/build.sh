#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv virus-interpreter*.jar $TGT/virusinterpreter.jar

cp $RECIPE_DIR/virusinterpreter.sh $TGT/virusinterpreter
ln -s $TGT/virusinterpreter $PREFIX/bin
chmod 0755 "${PREFIX}/bin/virusinterpreter"
