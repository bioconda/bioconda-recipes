#!/bin/bash

set -euxo pipefail

## Choose extra configure options depending on the operating system
## (mac or linux)
##
if [ `uname` == Darwin ] ; then
    export LDFLAGS="${LDFLAGS:-} -Wl,-headerpad_max_install_names"
fi

export PERL="${PREFIX}/bin/perl"
export PYTHON="${PYTHON}"

## Configure and make
./configure --prefix="${PREFIX}" \
            --with-kinwalker \
            --with-cluster \
            --disable-lto \
            --without-doc \
            --without-cla \
            --without-rnaxplorer \
            --disable-silent-rules

make -j"${CPU_COUNT}"

## Install
make install

"${PERL}" -MRNA -e 'print "perl ok\n"'
"${PYTHON}" -c 'import RNA; print("python ok")'
