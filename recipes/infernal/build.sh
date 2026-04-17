#!/bin/bash

set -ex

export M4="${BUILD_PREFIX}/bin/m4"
export INCLUDE_PATH="${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

grep -l -r "/usr/bin/perl" . | xargs sed -i.bak -e 's/usr\/bin\/perl/usr\/bin\/env perl/g'

autoreconf -if

case $(uname -m) in
    "x86_64") 
        ARCH_OPTS="--enable-sse"
        ;;
    "aarch64")
        # Download newer config.{sub,guess} files that support aarch64-conda-linux-gnu
        wget "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD" -O config.guess
        wget "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD" -O config.sub
        ;;
    *) 
        ;;
esac

./configure --prefix="${PREFIX}" CC="${CC}" CFLAGS="${CFLAGS} -O3 -L${PREFIX}/lib" "${ARCH_OPTS}"
make -j${CPU_COUNT}
make install
