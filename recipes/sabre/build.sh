#!/bin/bash

make CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"

install -d "${PREFIX}/bin"
install sabre "${PREFIX}/bin/"
