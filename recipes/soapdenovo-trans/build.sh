#!/bin/bash

pushd src
make CC="${CC}" CFLAGS="${CFLAGS} -O3 -fomit-frame-pointer" LIBPATH="${LDFLAGS}"
make CC="${CC}" CFLAGS="${CFLAGS} -O3 -fomit-frame-pointer" LIBPATH="${LDFLAGS}" 127mer=1
popd

install -d "${PREFIX}/bin"
install \
    SOAPdenovo-Trans-127mer \
    SOAPdenovo-Trans-31mer \
    "${PREFIX}/bin/"
