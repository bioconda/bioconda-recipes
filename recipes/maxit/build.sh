#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 ${LDFLAGS}"
export RCSBROOT=${PREFIX}
export PATH=${BUILD_PREFIX}/bin:${PATH}

cd ${SRC_DIR}/maxit-v10.1/src
sed -i.bak 's|rcsbroot = getenv("RCSBROOT")|rcsbroot = "'${PREFIX}'"|' maxit.C process_entry.C generate_assembly_cif_file.C
rm -rf *.bak

cd ${SRC_DIR}/cifparse-obj-v7.0
sed -i.bak 's/mv /cp /' Makefile
rm -rf *.bak

cd ${SRC_DIR}
sed -i.bak 's|./data/binary|'"${PREFIX}/data/binary"'|g' binary.sh
rm -rf *.bak

make compile CC="${CC}" CFLAGS="${CFLAGS}"
make binary -j"${CPU_COUNT}" CC="${CC}" CFLAGS="${CFLAGS}"

install -d ${PREFIX}/bin
install bin/* ${PREFIX}/bin
install -d ${PREFIX}/data
install -m 644 data/* ${PREFIX}/data
