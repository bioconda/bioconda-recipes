#!/bin/bash

# Object files/libraries in wrong order => can't use --as-needed.
# (and clange does not seem to support --no-as-needed).
export LDFLAGS="${LDFLAGS//-Wl,--as-needed/}"
make CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"

install -d "${PREFIX}/bin"
install \
    velvetg \
    velveth \
    *.pl \
    "${PREFIX}/bin/"
