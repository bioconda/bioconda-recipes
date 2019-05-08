#!/bin/bash

mkdir -p ${PREFIX}/lib/igv
cp lib/*.jar ${PREFIX}/lib/igv/
cp igv.args ${PREFIX}/lib/igv/igv.args

sed -i.bak 's|${prefix}/lib|'"${PREFIX}"'/lib/igv|g' igv.sh igv_hidpi.sh
sed -i.bak 's|${prefix}/igv.args|'"${PREFIX}"'/lib/igv/igv.args|g' igv.sh igv_hidpi.sh

cp igv.sh ${PREFIX}/bin/igv
cp igv_hidpi.sh ${PREFIX}/bin/igv_hidpi.sh

