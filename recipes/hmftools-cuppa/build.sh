#!/bin/bash

TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p $TGT/{,chart/}
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv jar/cuppa*.jar $TGT/cuppa.jar
${PYTHON} -m pip install --no-build-isolation --no-deps --no-cache-dir -vvv src/cuppa/src/main/python/pycuppa/

cp $RECIPE_DIR/cuppa.sh $TGT/cuppa
ln -s $TGT/cuppa ${PREFIX}/bin/
