#!/bin/bash -e

# loading the pytorch c++ libs
if [ "wget" == "wget" ]; then
    if [[ ${target_platform} =~ linux.* ]]; then
        curl https://download.pytorch.org/libtorch/cpu/libtorch-shared-with-deps-1.12.0%2Bcpu.zip \
            --output libtorch.zip
        export LIBTORCH_CXX11_ABI=0
    elif [[ ${target_platform} =~ osx.* ]]; then
        curl https://download.pytorch.org/libtorch/cpu/libtorch-macos-1.12.0.zip \
            --output libtorch.zip
    fi
    unzip libtorch.zip -d ${PREFIX}
    rm libtorch.zip
    export LIBTORCH=${PREFIX}/libtorch
else
    # This doesnt seem to work at all
    conda install pytorch=1.12 pytorch-cpu -c pytorch -c nvidia
    export LIBTORCH=$(python -c 'import torch; from pathlib import Path; print(Path(torch.__file__).parent)')
    export LIBTORCH_CXX11_ABI=0
fi
# add to library path
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${LIBTORCH}/lib
export DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}:${LIBTORCH}/lib

# TODO: Remove the following export when pinning is updated and we use
#       {{ compiler('rust') }} in the recipe.
export \
    CARGO_NET_GIT_FETCH_WITH_CLI=true \
    CARGO_HOME="${BUILD_PREFIX}/.cargo"

export BINDGEN_EXTRA_CLANG_ARGS="${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"

cargo install --no-track --verbose --root "${PREFIX}" --path . --features cnn
ft --help
