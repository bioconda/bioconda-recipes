#!/bin/bash

set -ex

grep -l -r "/usr/bin/perl" . | xargs sed -i.bak -e 's/usr\/bin\/perl/usr\/bin\/env perl/g'

autoreconf -i

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

./configure --prefix="${PREFIX}" "${ARCH_OPTS}"
make -j${CPU_COUNT}
make install
