#!/bin/bash

cd src
make \
    CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" \
    CFLAGS_OMP='$(CFLAGS) -fopenmp' \
    GIT_VERSION="${PKG_VERSION}"

install -d "${PREFIX}/bin"
install booster "${PREFIX}/bin/"

