#!/bin/bash

# Build uses hard-coded references to gcc/g++/etc. and does not properly honor all *FLAGS.
make_wrapper() {
    [ -n "${2:+x}" ] || return 0
    local exe
    exe="${BUILD_PREFIX}/bin/${3}"
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

{
cat <<end-of-patch
--- libs/kns/tls.c
+++ libs/kns/tls.c
@@ -431,4 +431,5 @@
         const char * root_ca_paths [] =
         {
+            "${PREFIX}", /* conda-forge::ca-certificates */
             "/etc/ssl/certs/ca-certificates.crt",                /* Debian/Ubuntu/Gentoo etc */
             "/etc/pki/tls/certs/ca-bundle.crt",                  /* Fedora/RHEL */
end-of-patch
} | patch -p0 -i-

./configure \
    --prefix=$PREFIX \
    --build-prefix=$NCBI_OUTDIR \
    --with-ngs-sdk-prefix=$PREFIX
# Make target dependencies seems broken; build fails with -j"${CPU_COUNT}"
make
popd

echo "compiling sra-tools"
pushd sra-tools

pushd tools/driver-tool/utf8proc
make -j${CPU_COUNT}
popd

./configure \
    --prefix=$PREFIX \
    --build-prefix=$NCBI_OUTDIR \
    --with-ngs-sdk-prefix=$PREFIX \
    --with-ncbi-vdb-build=$NCBI_OUTDIR
make -j${CPU_COUNT}
make install
popd

# Strip package version from binary names
cd $PREFIX/bin
ln -s fastq-dump-orig.$PKG_VERSION fastq-dump-orig
ln -s fasterq-dump-orig.$PKG_VERSION fasterq-dump-orig
ln -s prefetch-orig.$PKG_VERSION prefetch-orig
ln -s sam-dump-orig.$PKG_VERSION sam-dump-orig
ln -s srapath-orig.$PKG_VERSION srapath-orig
ln -s sra-pileup-orig.$PKG_VERSION sra-pileup-orig
