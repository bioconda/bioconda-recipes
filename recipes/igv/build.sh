#!/bin/bash

mkdir -p ${PREFIX}/lib/igv

# Build
$SRC_DIR/gradlew createDist

# Copy libs and start-up scripts
export IGV_BUILD_DIR=$SRC_DIR/build/IGV-dist

cp -r $IGV_BUILD_DIR/lib/* ${PREFIX}/lib/igv/
cp -r $IGV_BUILD_DIR/igv.args ${PREFIX}/lib/igv/igv.args

## Edit file paths in start-up scripts to point to new locations
pushd $IGV_BUILD_DIR

sed -i.bak 's|${prefix}/lib|'"${PREFIX}"'/lib/igv|g' igv.sh igv_hidpi.sh
sed -i.bak 's|${prefix}/igv.args|'"${PREFIX}"'/lib/igv/igv.args|g' igv.sh igv_hidpi.sh
## Copy scripts
cp igv.sh ${PREFIX}/bin/igv
cp igv_hidpi.sh ${PREFIX}/bin/igv_hidpi

popd

chmod a+x ${PREFIX}/bin/{igv,igv_hidpi}
