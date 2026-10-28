#!/bin/bash

cd segemehl
make -j"${CPU_COUNT}" CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" segemehl.x
make -j"${CPU_COUNT}" CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" testrealign.x
make -j"${CPU_COUNT}" CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" lack.x

install -d "${PREFIX}/bin"
install \
    segemehl.x \
    testrealign.x \
    lack.x \
    "${PREFIX}/bin/"
