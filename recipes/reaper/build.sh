#!/bin/bash

cd src
make CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"
install -d "${PREFIX}/bin"
install \
    minion \
    reaper \
    swan \
    tally \
    "${PREFIX}/bin/"
