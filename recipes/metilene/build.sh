#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "${PREFIX}/bin"
install -d "${PREFIX}/share/doc/metilene"

make CC="${CC}" -j"${CPU_COUNT}"

install -v -m 0755 metilene metilene_input.pl metilene_output.pl metilene_output.R "${PREFIX}/bin"
install -v manual.pdf "${PREFIX}/share/doc/metilene"
install -v README "${PREFIX}/share/doc/metilene"
