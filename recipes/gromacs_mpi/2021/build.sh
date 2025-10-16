#!/bin/bash

DENSITY_FILE="$SRC_DIR/src/gromacs/applied_forces/densityfitting/densityfitting.cpp"
sed -i '45a #include "gromacs/selection/indexutil.h"' "${DENSITY_FILE}"
sed -i '/#ifndef GMX_UTILITY_FLAGS_H/a #include <cstdint>' ../src/gromacs/utility/flags.h
sed -i '/#ifndef GMX_OPTIONS_OPTIONFLAGS_H/a #include <cstdint>' ../src/gromacs/options/optionflags.h

cmake_args=(
    -DGMX_MPI=ON
    -DGMX_BUILD_OWN_FFTW=OFF
    -DCMAKE_PREFIX_PATH="${PREFIX}"
    -DCMAKE_INSTALL_PREFIX="${PREFIX}"
    -DBUILD_SHARED_LIBS=ON
    -DGMX_PREFER_STATIC_LIBS=NO
)

case "$(uname -s)-$(uname -m)" in
    Darwin-*)
        # macOS 
        export MACOSX_DEPLOYMENT_TARGET=11.0
        source "${PREFIX}/etc/conda/activate.d/activate_llvm_openmp.sh"
        cmake_args+=(
            -DGMX_GPU=OpenCL
            -DOPENCL_LIBRARY="${PREFIX}/lib/libOpenCL.dylib"
            -DCMAKE_OSX_SYSROOT="/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
        )
        ;;
    Linux-x86_64)
        # Linux-x86_64
        cmake_args+=(
            -DGMX_GPU=OpenCL
            -DGMX_SIMD=AVX2_256 
        )
        ;;
    Linux-aarch64)
        # Linux-aarch64 
        cmake_args+=(
            -DGMX_GPU=OFF         # ARM 
            -DGMX_SIMD=ARM_NEON   # ARM NEON 
        )
        ;;
    *)
        echo "ERROR: Unsupported platform: $(uname -s)-$(uname -m)"
        exit 1
        ;;
esac
mkdir -p build && cd build
cmake .. "${cmake_args[@]}"
make -j "${CPU_COUNT}"
make install

# --------------------- （x86_64） ---------------------
if [[ "$(uname -m)" == "x86_64" ]]; then
    "${CXX}" -O3 -mavx512f -std=c++11 \
        -DGMX_IDENTIFY_AVX512_FMA_UNITS_STANDALONE=1 \
        -o "${PREFIX}/bin/identifyavx512fmaunits" \
        "${SRC_DIR}/src/gromacs/hardware/identifyavx512fmaunits.cpp"

    gmx='gmx_mpi'
    cat > "${PREFIX}/bin/${gmx}" <<EOF
#!/bin/bash
function _gromacs_bin_dir() {
    local arch='AVX2_256'
    if grep -q avx512f /proc/cpuinfo && \
       "${PREFIX}/bin/identifyavx512fmaunits" | grep -q '2'; then
        arch='AVX_512'
    fi
    echo "${PREFIX}/bin.\${arch}"
}
exec "\$( _gromacs_bin_dir )/${gmx}" "\$@"
EOF
    chmod +x "${PREFIX}/bin/${gmx}"
fi
