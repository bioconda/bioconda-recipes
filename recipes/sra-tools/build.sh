#!/bin/bash -e

export CFLAGS="${CFLAGS} -DH5_USE_110_API"

echo "compiling sra-tools"
if [[ $OSTYPE == "darwin"* ]]; then
    export CFLAGS="-DTARGET_OS_OSX $CFLAGS"
    export CXXFLAGS="-DTARGET_OS_OSX $CXXFLAGS"
fi

export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

mkdir -p obj/ngs/ngs-java/javadoc/ngs-doc  # prevent error on OSX


# Execute Make commands from a separate subdirectory. Else:
# ERROR: In source builds are not allowed
SRA_BUILD_DIR=./build_sratools
mkdir ${SRA_BUILD_DIR}
pushd ${SRA_BUILD_DIR}
cmake ../sra-tools/ -DVDB_BINDIR=${BUILD_PREFIX}/lib64 \
    -DVDB_LIBDIR=${BUILD_PREFIX}/lib64 \
    -DVDB_INCDIR=${BUILD_PREFIX}/include \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release
cmake --build .
cmake --install .
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
    ln -s "${exe}.${PKG_VERSION}" "${exe}"
done
