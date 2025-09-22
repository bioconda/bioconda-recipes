#!/bin/bash
mkdir -p "${PREFIX}/bin"

export CPPFLAGS="-I${PREFIX}/include -I${PREFIX}/include/htslib -I${PREFIX}/include/spoa"
export LDFLAGS="-L${PREFIX}/lib -lm -lhts -lz -llzma -lbz2 -lcurl -lcrypto -lspoa"

make LIBS='-L./ -L$(CEPHES_ROOT)/' \
    LongTR DenovoFinder PhasingChecker

install -v -m 0755 LongTR DenovoFinder PhasingChecker "${PREFIX}/bin"
