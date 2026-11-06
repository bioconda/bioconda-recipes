#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv fastq-tools*.jar $TGT/fastq-tools.jar

cp $RECIPE_DIR/fastq-tools.sh $TGT/fastq-tools
ln -s $TGT/fastq-tools $PREFIX/bin
chmod 0755 "${PREFIX}/bin/fastq-tools"
