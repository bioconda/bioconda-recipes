#!/bin/bash
set -euo pipefail

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/share/tcl/AnnotSV"

cp -f "share/tcl/AnnotSV/*" ${PREFIX}/share/tcl/AnnotSV/

install -v -m 0755 bin/INSTALL_annotations.sh "${PREFIX}/bin"

make install -j"${CPU_COUNT}"
