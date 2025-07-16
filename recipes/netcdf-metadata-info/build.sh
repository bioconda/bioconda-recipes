#!/bin/bash
make CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"
mkdir -p "$PREFIX/bin"
cp netcdf-metadata-info "$PREFIX/bin/"
