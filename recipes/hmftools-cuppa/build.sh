#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p $TGT
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv cuppa*.jar $TGT/cuppa.jar

cp $RECIPE_DIR/cuppa.sh $TGT/cuppa
ln -s $TGT/cuppa ${PREFIX}/bin/
chmod 0755 "${PREFIX}/bin/cuppa"

mkdir -p /tmp/cuppa_jar/
unzip -n $TGT/cuppa.jar -d /tmp/cuppa_jar/
${PYTHON} -m pip install --no-build-isolation --no-deps --no-cache-dir -vvv /tmp/cuppa_jar/pycuppa/
rm -r /tmp/cuppa_jar/
