#!/bin/sh

make \
    CC="${CXX}" \
    LINKER="${CXX}" \
    release
install -d "${PREFIX}/bin"
install fqtrim "${PREFIX}/bin/"
