#!/bin/bash

if [[ `uname` == Darwin ]]; then
	export CFLAGS="${CFLAGS} -O3 -Wno-int-conversion -Wno-implicit-function-declaration"
fi

# https://molpopgen.github.io/fwdpy11/misc/developersguide.html
# https://doc.rust-lang.org/cargo/commands/cargo-install.html
CARGO_INSTALL_ROOT=$BUILD_PREFIX CARGO_HOME=$CARGO_HOME cargo install cbindgen
#CARGO_INSTALL_ROOT=$PREFIX CARGO_HOME=$PREFIX cargo install cbindgen

# cmake's "find GSL macro" can barf when conda
# envs are involved, so we use GSL_ROOT_DIR to 
# fix that:
#GSL_ROOT_DIR=$PREFIX $PYTHON -m pip install --no-deps --ignore-installed -vv .
# for mac osx need also to add other vars:
CARGO_INSTALL_ROOT=$BUILD_PREFIX CARGO_HOME=$CARGO_HOME GSL_ROOT_DIR=$PREFIX $PYTHON -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv
# on bioconda's Azure it seems that `$PYTHON` variable is not set because get an error:
# /opt/conda/conda-bld/fwdpy11_1670108175931/work/conda_build.sh: line 16: -m: command not found
# so will hard-code it:
#CARGO_INSTALL_ROOT=$BUILD_PREFIX CARGO_HOME=$BUILD_PREFIX GSL_ROOT_DIR=$PREFIX python -m pip install --no-deps --ignore-installed -vv .

# for linux need:
tmp=`find $PREFIX -name libfwdpy11core.so` # $PREFIX/lib/python3.<n>/site-packages/fwdpy11/libfwdpy11core.so
[[ -f $tmp ]] && { echo FOUND $tmp; cp $tmp $PREFIX/lib; } || echo COULD NOT FIND libfwdpy11core.so
# (otherwise this libfwdpy11core.so is not found during test in $RPATH/libfwdpy11core.so and all fails; $RPATH equals $PREFIX/lib)
# (on mac osx this file extension is `.dylib` instead of `.so`, but there is no need to do this ... it might not be using RPATH ...)
