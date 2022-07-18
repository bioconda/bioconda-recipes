#!/bin/bash
make tgs \
    CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"

install -d "${PREFIX}/bin"
install \
    TransGeneScan \
    run_TransGeneScan.pl \
    processFragOut.py \
    post_process.pl \
    FGS_gff.py \
    "${PREFIX}/bin/"
