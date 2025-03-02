#!/bin/bash

git submodule init && git submodule update
make CC="${CC}" CFLAGS="-fcommon ${CFLAGS} ${LDFLAGS}" CPPFLAGS="${CPPFLAGS}"
mkdir -p "${PREFIX}/"{bin,include}
cp fml-asm ${PREFIX}/bin
cp *.h ${PREFIX}/include
