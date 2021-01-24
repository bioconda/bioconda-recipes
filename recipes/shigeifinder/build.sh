#!/bin/bash

mkdir -p $PREFIX/bin
cp -r * $PREFIX

#outdir="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
#mkdir -p "${outdir}"
#mkdir -p "${PREFIX}/bin"
#
#cp * "${outdir}/"
#chmod +x "${outdir}/shigeifinder.py"
#ln -s "${outdir}/shigeifinder.py" "${PREFIX}/bin/shigeifinder.py"