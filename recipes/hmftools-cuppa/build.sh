#!/bin/bash
#
TGT="$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
mv jar/cuppa*.jar $TGT/cuppa.jar
mv src/cuppa/src/main/resources/cuppa-chart/* $TGT/chart/

cp $RECIPE_DIR/cuppa.sh $TGT/cuppa
cp $RECIPE_DIR/cuppa-chart.sh $TGT/cuppa-chart
ln -s $TGT/cuppa{,-chart} ${PREFIX}/bin/
chmod 0755 "${PREFIX}/bin/cuppa{,-chart}"
