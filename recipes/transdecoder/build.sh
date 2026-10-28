#!/bin/bash

# install in opt/
mkdir -p "${PREFIX}/opt"

find ${SRC_DIR}/util -name '*.pl' -exec sed -i.bak 's/FindBin::Bin/FindBin::RealBin/' {} +
find ${SRC_DIR}/util -name '*.bak' -exec rm -f {} +
cp -Rf ${SRC_DIR} ${PREFIX}/opt/${PKG_NAME}

# symlink to binaries
mkdir -p "${PREFIX}/bin"

ln -sf "${PREFIX}/opt/${PKG_NAME}/TransDecoder" ${PREFIX}/bin/
for f in "${PREFIX}/opt/${PKG_NAME}/util/"*.pl; do
	ln -sf "$f" "${PREFIX}/bin/"
done
