#!/bin/bash

set -exo pipefail

# Disable parallel
export CPU_COUNT=1

export RCSBROOT="${SRC_DIR}"
export RCSBROOT="${SRC_DIR}"
export RCSBROOT="${SRC_DIR}"

ln -s "${CC}" "${BUILD_PREFIX}/bin/gcc"
ln -s "${CXX}" "${BUILD_PREFIX}/bin/c++"
ln -s "${CXX}" "${BUILD_PREFIX}/bin/cxx"
ln -s "${GXX}" "${BUILD_PREFIX}/bin/g++"

alias sed="${BUILD_PREFIX}/bin/sed"

cd ${SRC_DIR}/maxit-v10.1/src && \
sed -i "s|rcsbroot = getenv(\"RCSBROOT\")|rcsbroot = \"${RCSBROOT}\"|g" maxit.C process_entry.C generate_assembly_cif_file.C

cd "${SRC_DIR}/cifparse-obj-v7.0" && sed -i 's|mv |cp |g' Makefile
cd "${SRC_DIR}" && sed -i "s|./data/binary|${RCSBROOT}/data/binary|g" binary.sh
cd "${SRC_DIR}" && make binary -j${CPU_COUNT}

install -d "${PREFIX}/bin"
install ${SRC_DIR}/bin/* "${PREFIX}/bin"

install -d "${PREFIX}/data"
find "${SRC_DIR}/data" -type d -exec install -d "${PREFIX}/data/{}" \;
find "${SRC_DIR}/data" -type f -exec install -m 644 "{}" "${PREFIX}/data/{}" \;
