#!/bin/bash -e


# TODO: Ideally, we don't want the dynamic prefix-dependent patching below.
#       The following hard-codes the environment's path in binaries such that
#       those binaries have to be patched upon installation by conda
#       (with the usual downsides, e.g., being excluded from hard-linking).
#       This patch applies to a library which is statically linked such that
#       nearly all binaries of the package are affected by this.
{
cat <<end-of-patch
--- ncbi-vdb/libs/kns/tls.c
+++ ncbi-vdb/libs/kns/tls.c
@@ -431,4 +431,6 @@
         const char * root_ca_paths [] =
         {
+            "${PREFIX}/ssl/cacert.pem",                          /* conda-forge::ca-certificates */
+            "/usr/local/ssl/cacert.pem",                         /* path in docker */
             "/etc/ssl/certs/ca-certificates.crt",                /* Debian/Ubuntu/Gentoo etc */
             "/etc/pki/tls/certs/ca-bundle.crt",                  /* Fedora/RHEL */
end-of-patch
} | patch -p0 -i-


# Execute Make commands from a separate subdirectory. Else:
# ERROR: In source builds are not allowed
BUILD_DIR=./build_vdb
mkdir ${BUILD_DIR}
cd ${BUILD_DIR}

export CFLAGS="${CFLAGS} -DH5_USE_110_API"
cmake ../ncbi-vdb/ -DNGS_INCDIR=${PREFIX} \
         -DCMAKE_INSTALL_PREFIX=${PREFIX} \
         -DCMAKE_BUILD_TYPE=Release
cmake --build .
cmake --install .
