#!/bin/bash
set -euo pipefail

# The torch archive name differs per platform (see meta.yaml).
TORCH_LIB=$(echo "${SRC_DIR}"/download/torch-*/libtorch/lib)

if [[ "${target_platform}" == osx-* ]]; then
    TORCH_LIBS="libtorch.dylib libtorch_cpu.dylib libtorch_global_deps.dylib libc10.dylib"
else
    TORCH_LIBS="libtorch.so libtorch_cpu.so libtorch_cuda.so libtorch_global_deps.so
                libc10.so libc10_cuda.so libcaffe2_nvrtc.so"
fi
if [[ "${target_platform}" == "linux-aarch64" ]]; then
    # ONT's aarch64 libtorch references hypot/hypotf@GLIBC_2.35, which the
    # 2.34 sysroot lacks. They resolve at runtime (meta.yaml requires
    # __glibc >=2.35), so don't fail the link on them. libgomp comes from
    # conda-forge rather than the copy in the archive.
    export LDFLAGS="${LDFLAGS} -Wl,--allow-shlib-undefined"
elif [[ "${target_platform}" == "linux-64" ]]; then
    TORCH_LIBS="${TORCH_LIBS} libiomp5.so"
fi

cmake -S . -B build \
    ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=BOTH \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DDORADO_3RD_PARTY_DOWNLOAD="${SRC_DIR}/download" \
    -DOPENSSL_ROOT_DIR="${PREFIX}" \
    -DDORADO_DISABLE_TESTS=ON \
    -DDORADO_DISABLE_PACKAGING=ON \
    -DDORADO_DISABLE_CCACHE=ON

cmake --build build --parallel "${CPU_COUNT}" --target dorado

# Install by hand rather than with `cmake --install`, which would also copy
# CUDA toolkit libraries and libstdc++ into $PREFIX/lib and clash with the
# conda packages that provide them.
mkdir -p "${PREFIX}/bin" "${PREFIX}/lib/dorado"
install -m755 build/bin/dorado "${PREFIX}/bin/dorado"

# ONT's libtorch goes in a private directory so it cannot clash with
# conda-forge's libtorch. cuDNN and cuSPARSELt come from conda-forge instead
# of the copies bundled in the archive.
for lib in ${TORCH_LIBS}; do
    install -m755 "${TORCH_LIB}/${lib}" "${PREFIX}/lib/dorado/${lib}"
done

if [[ "${target_platform}" == osx-* ]]; then
    # Metal kernels; metallib-path.patch makes dorado look for them here.
    install -m644 build/lib/default.metallib "${PREFIX}/lib/dorado/default.metallib"

    # ONT's dylibs already find each other via @loader_path. Replace the
    # build-tree rpaths on dorado itself; dyld rejects duplicate LC_RPATHs,
    # so remove every entry before adding the two we want.
    "${OTOOL:-otool}" -l "${PREFIX}/bin/dorado" \
        | awk '/cmd LC_RPATH/ { getline; getline; print $2 }' \
        | while read -r rpath; do
            "${INSTALL_NAME_TOOL:-install_name_tool}" -delete_rpath "${rpath}" "${PREFIX}/bin/dorado"
        done
    "${INSTALL_NAME_TOOL:-install_name_tool}" \
        -add_rpath @loader_path/../lib/dorado \
        -add_rpath @loader_path/../lib \
        "${PREFIX}/bin/dorado"
else
    for lib in ${TORCH_LIBS}; do
        patchelf --set-rpath '$ORIGIN:$ORIGIN/..' "${PREFIX}/lib/dorado/${lib}"
    done
    patchelf --set-rpath '$ORIGIN/../lib/dorado:$ORIGIN/../lib' "${PREFIX}/bin/dorado"
fi
