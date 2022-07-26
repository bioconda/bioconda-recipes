#!/bin/sh
make all VIENNA="${PREFIX}" CXX="${CXX}"

mkdir -p "${PREFIX}/bin"
mv INFO-RNA-2.1.2 "${PREFIX}/bin/"
ln -s "${PREFIX}/bin/INFO-RNA-2.1.2" "${PREFIX}/bin/INFO-RNA"
