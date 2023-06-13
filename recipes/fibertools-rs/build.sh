#!/bin/bash -e

# Set the desitnation for the libtorch files
# OUTDIR=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
OUTDIR=${PREFIX}
mkdir -p ${OUTDIR} ${OUTDIR}/bin ${PREFIX}/bin

# set up environment variables
export LIBTORCH=${OUTDIR}
export LD_LIBRARY_PATH=${LIBTORCH}/lib #${LD_LIBRARY_PATH}:
export DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}:${LIBTORCH}/lib

# download pytorch libraries
export TORCH_VERSION="2.0.1"
export INSTALL_TYPE="cpu" # "cu117" or "cu118" or "cpu"
if [[ ${target_platform} =~ linux.* ]]; then
    export file=https://download.pytorch.org/libtorch/${INSTALL_TYPE}/libtorch-shared-with-deps-${TORCH_VERSION}%2B${INSTALL_TYPE}.zip
    export LIBTORCH_CXX11_ABI=0
    curl $file --output ${PREFIX}/libtorch.zip
elif [[ ${target_platform} =~ osx.* ]]; then
    # Add this becuase of this: https://twitter.com/nomad421/status/1619713549668065280
    export RUSTFLAGS="-C link-arg=-undefined -C link-arg=dynamic_lookup"
    export file=https://download.pytorch.org/libtorch/cpu/libtorch-macos-${TORCH_VERSION}.zip
    curl $file --output ${PREFIX}/libtorch.zip
fi

# move libtorch to OUTDIR
pushd ${PREFIX}
unzip -q libtorch.zip
rm libtorch.zip
popd
if [ ${PREFIX} != ${OUTDIR} ]; then
    mv ${PREFIX}/libtorch/* ${OUTDIR}/.
else
    mkdir -p ${OUTDIR}/include ${OUTDIR}/share ${OUTDIR}/lib
    mv ${PREFIX}/libtorch/lib/* ${OUTDIR}/lib/.
    mv ${PREFIX}/libtorch/include/* ${OUTDIR}/include/.
    mv ${PREFIX}/libtorch/share/* ${OUTDIR}/share/.
fi

# TODO: Remove the following export when pinning is updated and we use
#       {{ compiler('rust') }} in the recipe.
export \
    CARGO_NET_GIT_FETCH_WITH_CLI=true \
    CARGO_HOME="${BUILD_PREFIX}/.cargo"
export BINDGEN_EXTRA_CLANG_ARGS="${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"

# install package
HOME=$(pwd)
pushd ${PREFIX}
cargo install --all-features --no-track --verbose \
    --root "${PREFIX}" --path "${HOME}"
popd

# clean up the include files since they are not needed
# and there is a lot of them ~8,000
rm -rf ${OUTDIR}/include/*

# test install
ft --help
ldd "$(which ft)"

# try patchelf
if [[ ${target_platform} =~ linux.* ]]; then
    patchelf --print-needed $(which ft)
    OLD=${OUTDIR}/lib/libgomp-a34b3233.so.1
    OLD=${OUTDIR}/lib/libtorch_cpu.so
    NEW=${OUTDIR}/lib/libmine.so.1
    mv $OLD $NEW
    patchelf --replace-needed $OLD $NEW ${PREFIX}/bin/ft
    patchelf --replace-needed $(basename $OLD) $NEW ${PREFIX}/bin/ft

    ft --help
    ldd "$(which ft)"
fi
exit 0
