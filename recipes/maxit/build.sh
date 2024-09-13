#!/bin/bash

set -exo pipefail

# Disable parallel build
export CPU_COUNT=1

# export RCSBROOT="${SRC_DIR}"
# install -d "${PREFIX}/bin"

# To pass CI test on Linux
if [[ "$(uname -s)" == "Linux" ]]; then
    ulimit -v 2097152
fi

ln -s "${CC_FOR_BUILD}" "${BUILD_PREFIX}/bin/gcc"
ln -s "${CXX_FOR_BUILD}" "${BUILD_PREFIX}/bin/g++"

cd ${SRC_DIR}/maxit-v10.1/src && \
sed -i.bak "s|rcsbroot = getenv(\"RCSBROOT\")|rcsbroot = \"${PREFIX}\"|g" maxit.C process_entry.C generate_assembly_cif_file.C

cd "${SRC_DIR}/cifparse-obj-v7.0" && sed -i.bak 's|mv |cp |g' Makefile
# cd "${SRC_DIR}" && sed -i.bak "s|./data/binary|${PREFIX}/data/binary|g" binary.sh
cd "${SRC_DIR}" && make binary -j${CPU_COUNT}

unlink "${BUILD_PREFIX}/bin/gcc"
unlink "${BUILD_PREFIX}/bin/g++"

install -d "${PREFIX}/bin"
install ${SRC_DIR}/bin/* "${PREFIX}/bin"
cp -r "${SRC_DIR}/data" "${PREFIX}/data"

echo '"${PREFIX}/bin"'
ls -l ${PREFIX}/bin

echo '"${PREFIX}/data"'
ls -l ${PREFIX}/data
