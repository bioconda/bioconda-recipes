#!/bin/bash

make CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"
mkdir -p "${PREFIX}/bin"
cp zerone "${PREFIX}/bin/"
