#!/bin/bash

make \
    CC="${CXX}" \
    FLAGS="${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -D_NOSQLITE -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
mkdir -p "${PREFIX}/bin"
cp kronik "${PREFIX}/bin/"
