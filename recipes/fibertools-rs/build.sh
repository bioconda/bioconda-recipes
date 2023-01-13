#!/bin/bash -e

# loading the pytorch c++ libs
if [[ ${target_platform} =~ linux.* ]]; then
    curl https://download.pytorch.org/libtorch/cpu/libtorch-cxx11-abi-shared-with-deps-1.12.0%2Bcpu.zip \
        --output libtorch.zip
elif [[ ${target_platform} =~ osx.* ]]; then
    curl https://download.pytorch.org/libtorch/cpu/libtorch-macos-1.12.0.zip \
        --output libtorch.zip
fi
unzip libtorch.zip -d ${PREFIX}
rm libtorch.zip
echo "ls PREFIX"
ls ${PREFIX}
echo "ls PREFIX/libtorch"
ls ${PREFIX}/libtorch/
export LIBTORCH=${PREFIX}/libtorch
export LD_LIBRARY_PATH=${LIBTORCH}/lib:${LD_LIBRARY_PATH}
export DYLD_LIBRARY_PATH=${LIBTORCH}/lib:${DYLD_LIBRARY_PATH}
#export LIBTORCH_CXX11_ABI=0

# TODO: Remove the following export when pinning is updated and we use
#       {{ compiler('rust') }} in the recipe.
export \
    CARGO_NET_GIT_FETCH_WITH_CLI=true \
    CARGO_HOME="${BUILD_PREFIX}/.cargo"

export BINDGEN_EXTRA_CLANG_ARGS="${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"

cargo install --no-track --verbose --root "${PREFIX}" --path . --features cnn
ft --help
