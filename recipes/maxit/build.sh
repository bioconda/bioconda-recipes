#!/bin/bash

set -exo pipefail

# export INCLUDE_PATH="${PREFIX}/include"
# export LIBRARY_PATH="${PREFIX}/lib"
# export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 ${LDFLAGS}"
export CPU_COUNT=1
export RCSBROOT="${SRC_DIR}"

ln -s "${CC}" "${BUILD_PREFIX}/bin/gcc"
ln -s "${CXX}" "${BUILD_PREFIX}/bin/c++"
ln -s "${CXX}" "${BUILD_PREFIX}/bin/cxx"
ln -s "${GXX}" "${BUILD_PREFIX}/bin/g++"

alias sed="${BUILD_PREFIX}/bin/sed"

cd ${SRC_DIR}/maxit-v10.1/src && \
sed -i "s|rcsbroot = getenv(\"RCSBROOT\")|rcsbroot = \"${RCSBROOT}\"|g" maxit.C process_entry.C generate_assembly_cif_file.C

cd "${SRC_DIR}/cifparse-obj-v7.0" && sed -i 's|mv |cp |' Makefile
# cd "${SRC_DIR}" && sed -i "s|./data/binary|${PREFIX}/data/binary|g" binary.sh

# install -d "${SRC_DIR}"/bin
# install -d "${SRC_DIR}"/bin "${PREFIX}/bin"

cd "${SRC_DIR}" && make binary

# unlink ${BUILD_PREFIX}/bin/gcc
# unlink ${BUILD_PREFIX}/bin/c++
# unlink ${BUILD_PREFIX}/bin/cxx
# unlink ${BUILD_PREFIX}/bin/g++

install ${SRC_DIR}/bin/* "${PREFIX}/bin"

install -d -m 644 "${PREFIX}/data"
cp -r "${SRC_DIR}"/data/* "${PREFIX}/data"
