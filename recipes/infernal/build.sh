#!/bin/bash

set -ex

grep -l -r "/usr/bin/perl" . | xargs sed -i.bak -e 's/usr\/bin\/perl/usr\/bin\/env perl/g'

case $(uname -m) in
    "x86_64") 
        ARCH_OPTS="--enable-sse --enable-mpi" 
        ;;
    *) 
        ARCH_OPTS="--host=aarch64-unknown-linux-gnu --enable-mpi" 
        ;;
esac

autoreconf -i
./configure --prefix="${PREFIX}" "${ARCH_OPTS}"
make -j 2
make install
