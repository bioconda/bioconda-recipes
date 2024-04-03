#!/bin/bash

set -ex

grep -l -r "/usr/bin/perl" . | xargs sed -i.bak -e 's/usr\/bin\/perl/usr\/bin\/env perl/g'

case $(uname -m) in
    "x86_64") 
        ARCH_OPTS="--enable-sse" 
        ;;
    *) 
        ARCH_OPTS="" 
        ;;
esac

autoreconf -i
./configure --prefix="${PREFIX}" "${ARCH_OPTS}"
make -j 2
make install
