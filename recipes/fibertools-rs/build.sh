#!/bin/bash -e

TORCH_VERSION="2.0.1"
INSTALL_TYPE="cpu" # "cu117" or "cu118" or "cpu"
if [[ ${target_platform} =~ linux.* ]]; then
    file=https://download.pytorch.org/libtorch/${INSTALL_TYPE}/libtorch-shared-with-deps-${TORCH_VERSION}%2B${INSTALL_TYPE}.zip
    curl $file --output ${PREFIX}/libtorch.zip
    export LIBTORCH_CXX11_ABI=0
elif [[ ${target_platform} =~ osx.* ]]; then
    curl https://download.pytorch.org/libtorch/cpu/libtorch-macos-${TORCH_VERSION}.zip \
        --output ${PREFIX}/libtorch.zip
fi

# safe place to keep libraries?
OUTDIR=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
OUTDIR=${PREFIX}
mkdir -p ${OUTDIR} ${OUTDIR}/bin ${PREFIX}/bin

# mv libtorch to OUTDIR
pushd ${PREFIX}
unzip -q libtorch.zip
rm libtorch.zip
popd
if [ ${PREFIX} != ${OUTDIR} ]; then
    mv ${PREFIX}/libtorch/* ${OUTDIR}/.
else
    mv ${PREFIX}/libtorch/lib/* ${OUTDIR}/lib/.
    mv ${PREFIX}/libtorch/include/* ${OUTDIR}/include/.
    mv ${PREFIX}/libtorch/share/* ${OUTDIR}/share/.
fi

# set up environment variables
export LIBTORCH=${OUTDIR}
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${LIBTORCH}/lib
export DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}:${LIBTORCH}/lib

echo "This is the output dir: $OUTDIR"
ls $OUTDIR

# TODO: Remove the following export when pinning is updated and we use
#       {{ compiler('rust') }} in the recipe.
export \
    CARGO_NET_GIT_FETCH_WITH_CLI=true \
    CARGO_HOME="${BUILD_PREFIX}/.cargo"
export BINDGEN_EXTRA_CLANG_ARGS="${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"

# Add this becuase of this: https://twitter.com/nomad421/status/1619713549668065280
if [[ -n "$OSX_ARCH" ]]; then
    # Set this so that it doesn't fail with open ssl errors
    export RUSTFLAGS="-C link-arg=-undefined -C link-arg=dynamic_lookup"
fi

# install package
HOME=$(pwd)
pushd ${OUTDIR}
cargo install --all-features --no-track --verbose --root "${OUTDIR}" --path ${HOME}
popd

# link binary
if [ ${PREFIX} != ${OUTDIR} ]; then
    ln -s ${OUTDIR}/bin/ft ${PREFIX}/bin/ft
fi
chmod +x ${PREFIX}/bin/ft

# test install
ft --help
ldd $(which ft)
exit 0
