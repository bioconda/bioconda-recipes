#!/bin/bash -e

#
# Set the desitnation for the libtorch files
#
OUTDIR=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
mkdir -p ${OUTDIR} ${OUTDIR}/bin ${PREFIX}/bin
OUTDIR=${PREFIX}

#
# set up environment variables
#
export LIBTORCH=${OUTDIR}
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${LIBTORCH}/lib
export DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}:${LIBTORCH}/lib

#
# download pytorch libraries
#
export TORCH_VERSION="2.0.1"
export INSTALL_TYPE="cu118" # "cu117" or "cu118" or "cpu"
export INSTALL_TYPE="cpu"
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

#
# unpack the libtorch libs
#
pushd ${PREFIX}
unzip -q libtorch.zip
rm libtorch.zip
# give the libtorch things a different SONAME
# patchelf --set-soname $SONAME $F
popd

#
# move libtorch to OUTDIR
#
if [ ${PREFIX} != ${OUTDIR} ]; then
    mv ${PREFIX}/libtorch/* ${OUTDIR}/.
else
    mkdir -p ${OUTDIR}/include ${OUTDIR}/share ${OUTDIR}/lib
    mv ${PREFIX}/libtorch/lib/* ${OUTDIR}/lib/.
    mv ${PREFIX}/libtorch/include/* ${OUTDIR}/include/.
    mv ${PREFIX}/libtorch/share/* ${OUTDIR}/share/.
fi

#
# fix conflict with libgomp
#
if [[ ${target_platform} =~ linux.* ]]; then
    # this finally worked!!! getting rid of the pytorch version
    rm -f ${OUTDIR}/lib/libgomp-a34b3233.so.1
    ln -s ${PREFIX}/lib/libgomp.so.1.0.0 ${OUTDIR}/lib/libgomp-a34b3233.so.1
    #rm -f ${OUTDIR}/lib/libcudart-d0da41ae.so.11.0
    #ln -s ${PREFIX}/lib/libcudart.so.11.* ${OUTDIR}/lib/libcudart-d0da41ae.so.11.0
    echo "Using the included libgomp"
fi

#
# TODO: Remove the following export when pinning is updated and we use
#       {{ compiler('rust') }} in the recipe.
export \
    CARGO_NET_GIT_FETCH_WITH_CLI=true \
    CARGO_HOME="${BUILD_PREFIX}/.cargo"
export BINDGEN_EXTRA_CLANG_ARGS="${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"

#
# install package
#
HOME=$(pwd)
pushd ${PREFIX}
cargo install --all-features --no-track --verbose \
    --root "${PREFIX}" --path "${HOME}"
popd

#
# clean up the include files since they are not needed and there is a lot of them ~8,000
#
rm -rf ${OUTDIR}/include/*
if [[ ${target_platform} =~ linux.* ]]; then
    # clean up the static libraries since they are not needed
    rm ${OUTDIR}/lib/*.a
fi

#
# test install
#
ft --help

#
# try patchelf
#
if [[ ${target_platform} =~ linux.* ]]; then
    ldd "$(which ft)"
    patchelf --print-needed $(which ft)
    #for OLD in ${PREFIX}/lib/libgomp.so*; do
    #    NEW=${OUTDIR}/lib/libgomp-a34b3233.so.1
    #    patchelf --debug --replace-needed $OLD $NEW ${PREFIX}/bin/ft
    #    patchelf --debug --replace-needed $(basename $OLD) $NEW ${PREFIX}/bin/ft
    #done
    #echo "after patchelf"
    #patchelf --print-needed $(which ft)
    #OLD=${OUTDIR}/lib/libtorch_cpu.so
    #NEW=${OUTDIR}/lib/libmine.so.1
    #mv $OLD $NEW
    #patchelf --replace-needed $OLD $NEW ${PREFIX}/bin/ft
    #patchelf --replace-needed $(basename $OLD) $NEW ${PREFIX}/bin/ft
    #patchelf --set-rpath \$ORIGIN/../lib ${PREFIX}/bin/ft
    #ft --help
    #ldd "$(which ft)"
    #patchelf --print-needed $(which ft)
fi

#
# test install on data
#
pushd ${HOME}
ft m6a -v tests/data/all.bam /dev/null
popd

exit 0
