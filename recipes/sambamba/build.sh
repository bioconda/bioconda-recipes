#!/bin/bash
set -eux

version='1.0.1'

export CC="$CC"
export C_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"

sed -e "/^CC=/d" 'Makefile' > 'Makefile.new'
mv 'Makefile.new' 'Makefile'
if [[ "$(uname)" == 'Darwin' ]]
then
    # Clang doesn't support '-flto=full'.
    sed -e "/^LDFLAGS/d" 'Makefile' > 'Makefile.new'
    mv 'Makefile.new' 'Makefile'
    # Will run into linkage issues with ldc2 otherwise.
    unset -v LDFLAGS
fi
make CC="$CC" LIBRARY_PATH="$LIBRARY_PATH" release
make check
bin_dir="${PREFIX}/bin"
mkdir -pv "$bin_dir"
cp "bin/sambamba-${version}" --target-directory="$bin_dir"
(
    cd "$bin_dir"
    ln -s "sambamba-${version}" 'sambamba'
)
