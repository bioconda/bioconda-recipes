#!/bin/bash
set -euo pipefail

TORCH_LIB="${SRC_DIR}/download/torch-2.9.0.0-ont-CUDA-12.8-linux-x64-cxx11-abi/libtorch/lib"

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
for lib in libtorch.so libtorch_cpu.so libtorch_cuda.so libtorch_global_deps.so \
           libc10.so libc10_cuda.so libcaffe2_nvrtc.so libiomp5.so; do
    install -m755 "${TORCH_LIB}/${lib}" "${PREFIX}/lib/dorado/${lib}"
    patchelf --set-rpath '$ORIGIN:$ORIGIN/..' "${PREFIX}/lib/dorado/${lib}"
done
patchelf --set-rpath '$ORIGIN/../lib/dorado:$ORIGIN/../lib' "${PREFIX}/bin/dorado"
