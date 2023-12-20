#!/bin/sh

"${FC}" ${FFLAGS} -o EMMIX EMMIX.f

mkdir -p "${PREFIX}/bin"
mv EMMIX "${PREFIX}/bin/"
