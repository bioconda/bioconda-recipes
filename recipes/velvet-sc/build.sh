#!/bin/bash

# Adding "-Wl,--no-as-needed" since link objects are in wrong order.
make CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS} -Wl,--no-as-needed"

install -d "${PREFIX}/bin"
install \
    velvetg \
    velveth \
    *.pl \
    "${PREFIX}/bin/"
