#!/bin/bash
set -xeuo pipefail

# This script uses ideas from the build script for BLAST. See comments there.

SHARE_DIR=$PREFIX/share/igblast

mkdir -p $PREFIX/bin

# $SHARE_DIR contains the actual igblastn and igblastp binaries and also the
# required data files. Wrappers will be installed into $PREFIX/bin that set
# $IGDATA to point to those data files.
mkdir -p $SHARE_DIR/bin

if [[ $(uname) == Linux ]]; then
    export CPPFLAGS="$CPPFLAGS -I$PREFIX/include/ncbi-vdb"
    export CC_FOR_BUILD=$CC
    export AR="$AR rcs"

    cd c++

    # IgBLAST is based on the BLAST source code and building it produces
    # a similar set of shared libraries if --with-dll is used. To avoid
    # conflicts when installing IgBLAST and BLAST simultaneously,
    # we link IgBLAST statically.
    ./configure.orig \
        --with-static-exe \
        --with-mt \
        --with-openmp \
        --without-autodep \
        --without-makefile-auto-update \
        --with-flat-makefile \
        --with-caution \
        --without-lzo \
        --without-debug \
        --with-strip \
        --with-z=$PREFIX \
        --with-bz2=$PREFIX \
        --with-vdb=$PREFIX \
        --without-krb5 \
        --without-openssl \
        --without-gnutls \
        --without-gcrypt \
        --with-build-root=ReleaseMT \
        --prefix=$PREFIX
    make -j2
    # Move one up so it looks like the binary release
    mv ReleaseMT/bin .
    mv src/app/igblast/{internal_data,optional_file} $SHARE_DIR
else
    # On macOS, prebuilt binaries are used
    mv internal_data optional_file $SHARE_DIR
fi
mv bin/makeblastdb $PREFIX/bin/
mv bin/{igblastn,igblastp} $SHARE_DIR/bin/

# Replace the shebang
sed '1 s_^.*$_#!/usr/bin/env perl_' bin/edit_imgt_file.pl > $PREFIX/bin/edit_imgt_file.pl
chmod +x $PREFIX/bin/edit_imgt_file.pl

# Install wrappers
for name in igblastn igblastp; do
  cat >"${PREFIX}/bin/${name}" <<EOF
#!/bin/sh
IGDATA="\${IGDATA-"${PREFIX}/share/igblast"}" exec "${PREFIX}/share/igblast/bin/${name}" "\${@}"
EOF
  chmod +x $PREFIX/bin/$name
done

# To Do
# - makeblastdb conflicts with the one from BLAST
