#!/usr/bin/env bash

set -e -o pipefail

outdir=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
mkdir -p ${outdir}

chmod a+x metapointfinder.py
mv metapointfinder.py ${outdir}
mv *.R ${outdir}
mv dependencies ${outdir}

ln -s ${outdir}/metapointfinder.py ${PREFIX}/bin/
