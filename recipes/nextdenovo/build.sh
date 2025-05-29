#!/bin/bash
set -ex

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export OUTDIR="${SP_DIR}/nextdenovo"

mkdir -p ${PREFIX}/bin ${OUTDIR}
cp -rf ${BUILD_PREFIX}/share/gnuconfig/config.* lib/htslib/

sed -i.bak 's|-O2|-O3|' lib/htslib/configure
sed -i.bak 's|-lpthread|-pthread|' lib/htslib/configure
rm -rf lib/htslib/*.bak
sed -i.bak 's|-O2|-O3|' minimap2/Makefile
sed -i.bak 's|-lpthread|-pthread|' minimap2/Makefile
rm -rf minimap2/*.bak

make CC="${CC}" CXX="${CXX}" INCLUDES="-I${PREFIX}/include" -j"${CPU_COUNT}"

install -v -m 0755 bin/* "${PREFIX}/bin"

cp -rf ${SRC_DIR}/* ${OUTDIR}
chmod 0755 ${OUTDIR}/nextDenovo
ln -sf ${OUTDIR}/nextDenovo ${PREFIX}/bin/nextDenovo
