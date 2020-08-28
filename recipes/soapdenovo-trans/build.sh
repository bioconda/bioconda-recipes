#!/bin/bash

pushd src
make CC="${CC}" LIBPATH="${LDFLAGS}"
make CC="${CC}" LIBPATH="${LDFLAGS}" 127mer=1
popd

install -d "${PREFIX}/bin"
install \
    SOAPdenovo-Trans-127mer \
    SOAPdenovo-Trans-31mer \
    "${PREFIX}/bin/"
