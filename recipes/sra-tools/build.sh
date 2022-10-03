#!/bin/bash -e

NCBI_OUTDIR=$SRC_DIR/ncbi-outdir


echo "compiling ncbi-vdb"
pushd ncbi-vdb

# TODO: Ideally, we don't want the dynamic prefix-dependent patching below.
#       The following hard-codes the environment's path in binaries such that
#       those binaries have to be patched upon installation by conda
#       (with the usual downsides, e.g., being excluded from hard-linking).
#       This patch applies to a library which is statically linked such that
#       nearly all binaries of the package are affected by this.
{
cat <<end-of-patch
--- libs/kns/tls.c
+++ libs/kns/tls.c
@@ -431,4 +431,5 @@
         const char * root_ca_paths [] =
         {
+            "${PREFIX}/ssl/cacert.pem", /* conda-forge::ca-certificates */
             "/etc/ssl/certs/ca-certificates.crt",                /* Debian/Ubuntu/Gentoo etc */
             "/etc/pki/tls/certs/ca-bundle.crt",                  /* Fedora/RHEL */
end-of-patch
} | patch -p0 -i-

export CFLAGS="${CFLAGS} -DH5_USE_110_API"
cmake -DNGS_INCDIR=${PREFIX} -DCMAKE_BUILD_TYPE=Release
cmake --build . --verbose

popd

echo "compiling sra-tools"
pushd sra-tools

if [[ $OSTYPE == "darwin"* ]]; then
    export CFLAGS="-DTARGET_OS_OSX $CFLAGS"
    export CXXFLAGS="-DTARGET_OS_OSX $CXXFLAGS"
fi

mkdir -p obj/ngs/ngs-java/javadoc/ngs-doc  # prevent error on OSX
export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
cmake -DVDB_BINDIR=${SRC_DIR}/ncbi-vdb/bin \
    -DVDB_LIBDIR=${SRC_DIR}/ncbi-vdb/lib \
    -DVDB_INCDIR=${SRC_DIR}/ncbi-vdb/interfaces \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release
cmake --build . --verbose
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
