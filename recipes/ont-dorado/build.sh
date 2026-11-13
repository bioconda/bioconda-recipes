#!/bin/bash
set -euo pipefail

# The torch archive name differs per architecture (see meta.yaml).
TORCH_LIB=$(echo "${SRC_DIR}"/download/torch-*/libtorch/lib)

TORCH_LIBS="libtorch.so libtorch_cpu.so libtorch_cuda.so libtorch_global_deps.so
            libc10.so libc10_cuda.so libcaffe2_nvrtc.so"
if [[ "${target_platform}" == "linux-aarch64" ]]; then
    # ONT's aarch64 libtorch references hypot/hypotf@GLIBC_2.35, which the
    # 2.34 sysroot lacks. They resolve at runtime (meta.yaml requires
    # __glibc >=2.35), so don't fail the link on them. libgomp comes from
    # conda-forge rather than the copy in the archive.
    export LDFLAGS="${LDFLAGS} -Wl,--allow-shlib-undefined"
else
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
install -Dm755 build/bin/dorado "${PREFIX}/bin/dorado"

# ONT's libtorch goes in a private directory so it cannot clash with
# conda-forge's libtorch. cuDNN and cuSPARSELt come from conda-forge instead
# of the copies bundled in the archive.
mkdir -p "${PREFIX}/lib/dorado"
for lib in ${TORCH_LIBS}; do
    install -m755 "${TORCH_LIB}/${lib}" "${PREFIX}/lib/dorado/${lib}"
    patchelf --set-rpath '$ORIGIN:$ORIGIN/..' "${PREFIX}/lib/dorado/${lib}"
done
patchelf --set-rpath '$ORIGIN/../lib/dorado:$ORIGIN/../lib' "${PREFIX}/bin/dorado"
