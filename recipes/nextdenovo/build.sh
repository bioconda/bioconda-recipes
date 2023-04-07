#!/bin/bash
set -x

PYVER=`python -c 'import sys; print(str(sys.version_info[0])+"."+str(sys.version_info[1]))'`
OUTDIR=${PREFIX}/lib/python${PYVER}/site-packages/nextdenovo

make CC=${CC} INCLUDES="-I$PREFIX/include -lcurl -lssl -lcrypto"

mkdir -p ${PREFIX}/bin ${OUTDIR}
cp -r -f ./bin/ ./lib/ ./nextDenovo ./test_data VERSION ${OUTDIR}
chmod a+x ${OUTDIR}/nextDenovo
ln -s ${OUTDIR}/nextDenovo ${PREFIX}/bin/nextDenovo