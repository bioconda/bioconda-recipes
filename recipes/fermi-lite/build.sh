#!/bin/bash

make CC="${CC}" CFLAGS="${CFLAGS} ${LDFLAGS}" CPPFLAGS="${CPPFLAGS}"
mkdir -p "${PREFIX}/"{bin,include}
cp fml-asm ${PREFIX}/bin
cp *.h ${PREFIX}/include
