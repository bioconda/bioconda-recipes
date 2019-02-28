#!/bin/bash

export LIBRARY_PATH="${PREFIX}/lib:/usr/lib:/usr/lib64:${LIBRARY_PATH}"
export LD_LIBRARY_PATH="${PREFIX}/lib:/usr/lib:/usr/lib64:${LD_LIBRARY_PATH}"
export LD_RUN_PATH="${PREFIX}/lib:/usr/lib:/usr/lib64:${LD_RUN_PATH}"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -I${PREFIX}/include"
export CPATH="${CPATH} ${PREFIX}/include"


# stack relies on $HOME, so fake it:
mkdir -p fake-home
export HOME=$PWD/fake-home
export STACK_ROOT="$HOME/.stack"
stack setup --system-ghc --local-bin-path ${PREFIX}/bin
make install WGET="wget --no-check-certificate" prefix=$PREFIX

#cleanup
rm -r .stack-work
