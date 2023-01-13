#!/bin/bash -e

# loading the pytorch c++ libs
export LIBTORCH=$(python -c 'import torch; from pathlib import Path; print(Path(torch.__file__).parent)')
export LD_LIBRARY_PATH=${LIBTORCH}/lib:#$LD_LIBRARY_PATH
export DYLD_LIBRARY_PATH=${LIBTORCH}/lib:#$LD_LIBRARY_PATH
export LIBTORCH_CXX11_ABI=0

# TODO: Remove the following export when pinning is updated and we use
#       {{ compiler('rust') }} in the recipe.
export \
    CARGO_NET_GIT_FETCH_WITH_CLI=true \
    CARGO_HOME="${BUILD_PREFIX}/.cargo"

export BINDGEN_EXTRA_CLANG_ARGS="${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"

cargo install --no-track --verbose --root "${PREFIX}" --path .
