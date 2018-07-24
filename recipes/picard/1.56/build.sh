#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

curl -o lib/ant/ant-apache-bcel-1.8.1.jar https://depot.galaxyproject.org/software/Ant-Apache-BCEL/Ant-Apache-BCEL_1.8.1_src_all.jar
ant -lib lib/ant/ package-commands
cp -R dist/* ${TGT}

cp $RECIPE_DIR/picard.sh $TGT/picard
ln -s $TGT/picard $PREFIX/bin
chmod 0755 "${PREFIX}/bin/picard"
