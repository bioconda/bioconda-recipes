#!/bin/bash

pushd SOAPdenovo-Trans
make CC="${CC} -fcommon" LIBPATH="${LDFLAGS}"
make CC="${CC} -fcommon" LIBPATH="${LDFLAGS}" 127mer=1
popd

install -d "${PREFIX}/bin"
install \
    SOAPdenovo-Trans-127mer \
    SOAPdenovo-Trans-31mer \
    "${PREFIX}/bin/"
