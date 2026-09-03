#!/bin/bash
set -ex

export LIBCLANG_PATH="${BUILD_PREFIX}/lib"
export BINDGEN_EXTRA_CLANG_ARGS="--sysroot=${CONDA_BUILD_SYSROOT}"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

${PYTHON} -m pip install . --no-deps --no-build-isolation -vvv
