#!/bin/bash
set -eux

export CC="$CC"
export C_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export VERSION='1.0.1'

sed -e "/^CC=/d" 'Makefile' > 'Makefile.new'
mv 'Makefile.new' 'Makefile'
if [[ "$(uname)" == 'Darwin' ]]
then
    ldflags_bak="$LDFLAGS"
    # Clang doesn't support '-flto=full'.
    sed -e "/^LDFLAGS/d" 'Makefile' > 'Makefile.new'
    mv 'Makefile.new' 'Makefile'
    # Will run into linkage issues with ldc2 otherwise.
    unset -v LDFLAGS
fi
make CC="$CC" LIBRARY_PATH="$LIBRARY_PATH" release
make check
if [[ "$(uname)" == 'Darwin' ]]
then
    LDFLAGS="$ldflags_bak"
fi
mkdir -pv "${PREFIX}/bin"
cp "bin/sambamba-${VERSION}" --target-directory="${PREFIX}/bin"
(
    cd "${PREFIX}/bin"
    ln -s "sambamba-${VERSION}" 'sambamba'
)
