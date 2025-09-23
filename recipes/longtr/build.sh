#!/bin/bash
mkdir -p "${PREFIX}/bin"

make LIBS="-L./ -L\$(CEPHES_ROOT)/ -L${PREFIX}/lib -lm -lhts -lspoa" \
    INCLUDE="-Ilib -I${PREFIX}/include -I${PREFIX}/include/htslib -I${PREFIX}/include/spoa" \
    HTSLIB_LIB='' \
    LongTR DenovoFinder

install -v -m 0755 LongTR DenovoFinder "${PREFIX}/bin"
