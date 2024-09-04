#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 ${LDFLAGS}"
export RCSBROOT=${SRC_DIR}
export CC=${PREFIX}/bin/gcc

# cd ${SRC_DIR}/maxit-v10.1/src
# sed -i.bak 's|rcsbroot = getenv("RCSBROOT")|rcsbroot = "'${RCSBROOT}'"|' maxit.C process_entry.C generate_assembly_cif_file.C
# rm -rf *.bak

# cd ${SRC_DIR}/cifparse-obj-v7.0
# sed -i 's/mv /cp /' Makefile

cd ${SRC_DIR}
sed -i 's|./data/binary|'"${RCSBROOT}/data/binary"'|g' binary.sh

# CC="${CC}" CFLAGS="${CFLAGS}" make compile
CC="${CC}" CFLAGS="${CFLAGS}" make binary -j"${CPU_COUNT}"

install -d ${PREFIX}/bin
install bin/* ${PREFIX}/bin
install -d ${PREFIX}/data
install -m 644 data/* ${PREFIX}/data
