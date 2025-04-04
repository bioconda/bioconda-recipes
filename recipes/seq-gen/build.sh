#!/bin/bash

cd source
make CLINKER="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"

install -d "${PREFIX}/bin"
install seq-gen "${PREFIX}/bin/"
