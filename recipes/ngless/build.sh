#!/usr/bin/env bash


export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"
export CFLAGS="-I$PREFIX/include"
export CPATH=${PREFIX}/include

# These are picked up by stack setup.
export fp_prog_ar=${PREFIX}/bin/x86_64-conda_cos6-linux-gnu-ar
export CONF_LD_LINKER_OPTS_STAGE2=-L${PREFIX}/lib
export CONF_GCC_LINKER_OPTS_STAGE2=-L${PREFIX}/lib

# stack relies on $HOME, so fake it:
stack setup --local-bin-path ${PREFIX}/bin
make install WGET="wget --no-check-certificate" prefix=$PREFIX

rm -r .stack-work
