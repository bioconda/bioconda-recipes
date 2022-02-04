#!/bin/bash

make CC="${CC} -fcommon ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"
install -d "${PREFIX}/bin"
install bin/matlock "${PREFIX}/bin/"
