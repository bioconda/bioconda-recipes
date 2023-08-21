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
    # Clang doesn't support '-flto=full'.
    sed -e "/^LDFLAGS/d" 'Makefile' > 'Makefile.new'
    mv 'Makefile.new' 'Makefile'
fi
make CC="$CC" LIBRARY_PATH="$LIBRARY_PATH" release
make check
mkdir -pv "${PREFIX}/bin"
cp "bin/sambamba-${VERSION}" --target-directory="${PREFIX}/bin"
(
    cd "${PREFIX}/bin"
    ln -s "sambamba-${VERSION}" 'sambamba'
)
