#!/bin/bash -e

# Build uses hard-coded references to gcc/g++/etc. and does not properly honor all *FLAGS.
make_wrapper() {
    [ -n "${2:+x}" ] || return 0
    local exe
    exe="${BUILD_PREFIX}/bin/${3}"
    rm -f "${exe}"
    touch "${exe}"
    chmod +x "${exe}"
    cat > "${exe}" <<EOF
#! /bin/sh
exec ${2} ${1} ${CPPFLAGS} ${LDFLAGS} "\${@}"
EOF
}
make_wrapper "${CFLAGS}" "${CC}" cc
make_wrapper "${CFLAGS}" "${GCC}" gcc
make_wrapper "${CFLAGS}" "${CLANG}" clang
make_wrapper "${CXXFLAGS}" "${CXX}" c++
make_wrapper "${CXXFLAGS}" "${GXX}" g++
make_wrapper "${CXXFLAGS}" "${CLANGXX}" clang++
ln -s "${AR}" "${BUILD_PREFIX}/bin/ar"
ln -s "${LD}" "${BUILD_PREFIX}/bin/ld"


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

./configure --help
./configure \
    --prefix="${PREFIX}" \
    --build-prefix="${NCBI_OUTDIR}" \
    --with-ngs-sdk-prefix="${PREFIX}" \
    --with-hdf5-prefix="${PREFIX}" \
    --with-xml2-prefix="${PREFIX}" \
    ;
# Make target dependencies seems broken; build fails with -j"${CPU_COUNT}"
make
popd

echo "compiling sra-tools"
pushd sra-tools

pushd tools/driver-tool/utf8proc
make -j"${CPU_COUNT}"
popd

./configure \
    --prefix="${PREFIX}" \
    --build-prefix="${NCBI_OUTDIR}" \
    --with-ngs-sdk-prefix="${PREFIX}" \
    --with-hdf5-prefix="${PREFIX}" \
    --with-xml2-prefix="${PREFIX}" \
    --with-ncbi-vdb-build="${NCBI_OUTDIR}" \
    ;
make -j"${CPU_COUNT}"
make install
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
