#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv sv-prep*.jar $TGT/sv-prep.jar

cp $RECIPE_DIR/svprep.sh $TGT/svprep
cp $RECIPE_DIR/gridss_shell_with_jar_entrypoint $TGT/
cp $RECIPE_DIR/gridss_svprep.sh $TGT/gridss_svprep

ln -s $TGT/svprep $PREFIX/bin/
ln -s $TGT/gridss_shell_with_jar_entrypoint $PREFIX/bin/gridss_svprep
chmod 0755 ${PREFIX}/bin/{gridss_,}svprep
