#!/bin/bash -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

export CFLAGS="${CFLAGS} -O3 -DH5_USE_110_API -D_FILE_OFFSET_BITS=64 ${LDFLAGS}"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include ${LDFLAGS}"

echo "compiling sra-tools"
if [[ ${OSTYPE} == "darwin"* ]]; then
    export CFLAGS="${CFLAGS} -DTARGET_OS_OSX"
    export CXXFLAGS="${CXXFLAGS} -DTARGET_OS_OSX -D_LIBCPP_DISABLE_AVAILABILITY"
fi

mkdir -p obj/ngs/ngs-java/javadoc/ngs-doc  # prevent error on OSX


# Execute Make commands from a separate subdirectory. Else:
# ERROR: In source builds are not allowed
export SRA_BUILD_DIR=${SRC_DIR}/build_sratools
mkdir -p ${SRA_BUILD_DIR}
pushd ${SRA_BUILD_DIR}

cmake ../sra-tools/ -DVDB_BINDIR="${PREFIX}/lib64" \
    -DVDB_LIBDIR="${PREFIX}/lib64" \
    -DVDB_INCDIR="${PREFIX}/include" \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_COMPILER="${CXX}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}"

cmake --build . --target install -j 4 -v
popd


# Strip package version from binary names
cd "${PREFIX}/bin"
for exe in \
    fastq-dump-orig \
    fasterq-dump-orig \
    prefetch-orig \
    sam-dump-orig \
    srapath-orig \
    sra-pileup-orig
do
    ln -sf "${exe}.${PKG_VERSION}" "${exe}"
done
