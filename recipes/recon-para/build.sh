#!/bin/bash
set -ex

export CFLAGS="${CFLAGS} -O3 -Wno-unused-result -Wno-format -Wno-implicit-function-declaration"

mkdir -p ${PREFIX}/bin

cd src/
make CC="${CC}" CFLAGS="${CFLAGS}" -j"${CPU_COUNT}"
cp imagespread eledef eleredef edgeredef famdef ${PREFIX}/bin/

cd ../scripts/
sed -i.bak "s|\$path = \"\";|\$path = \"${PREFIX}/bin\";|" recon.pl && rm -f recon.pl.bak
install -v -m 0755 recon.pl ${PREFIX}/bin/
install -v -m 0755 MSPCollect.pl ${PREFIX}/bin/

chmod a+r "${SRC_DIR}/LICENSE"
