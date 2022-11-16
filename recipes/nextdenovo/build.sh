#!/bin/bash
set -x

PYVER=`python -c 'import sys; print(str(sys.version_info[0])+"."+str(sys.version_info[1]))'`
OUTDIR=${PREFIX}/lib/python${PYVER}/site-packages/nextdenovo
mkdir -p ${PREFIX}/bin ${OUTDIR}
cp -r ./* ${OUTDIR}
chmod a+x ${OUTDIR}/nextDenovo
ln -s ${OUTDIR}/nextDenovo ${PREFIX}/bin/nextDenovo

