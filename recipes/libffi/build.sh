#!/bin/bash

./configure --prefix=$PREFIX
make
make install

# Put headers in regular location
mkdir -p "${PREFIX}/include/"
mv "${PREFIX}"/lib/"${PKG_NAME}"-"${PKG_VERSION}"/include/*.h "${PREFIX}/include/"
rm -rf "${PREFIX}/lib/${PKG_NAME}-${PKG_VERSION}"
