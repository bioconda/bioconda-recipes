#!/bin/bash
mkdir build
cd build

## See INSTALL of gromacs distro
for ARCH in SSE2 AVX_256 AVX2_256 AVX_512; do
  cmake_args=(
    -DSHARED_LIBS_DEFAULT=ON
    -DBUILD_SHARED_LIBS=ON
    -DGMX_PREFER_STATIC_LIBS=NO
    -DGMX_BUILD_OWN_FFTW=OFF
    -DGMX_DEFAULT_SUFFIX=ON
    -DREGRESSIONTEST_DOWNLOAD=ON
    -DGMX_GPU=ON
    -DGMX_USE_OPENCL=ON
    -DCMAKE_PREFIX_PATH="${PREFIX}"
    -DGMX_INSTALL_PREFIX="${PREFIX}"
    -DCMAKE_INSTALL_PREFIX="${PREFIX}"
    -DGMX_SIMD="${ARCH}"
    -DCMAKE_INSTALL_BINDIR="bin.${ARCH}"
    -DCMAKE_INSTALL_LIBDIR="lib.${ARCH}"
  )
  if [[ "${mpi}" == "nompi" ]]; then
    cmake_args+=(-DGMX_MPI=OFF)
  else
    cmake_args+=(-DGMX_MPI=ON)
  fi
  cmake .. "${cmake_args[@]}"
  make -j "${CPU_COUNT}"
  make install
done


#
# Build the program to identify number of AVX512 FMA units
# This will only be executed on AVX-512-capable hosts. If there
# are dual AVX-512 FMA units, it will be faster to use AVX-512 SIMD, but if
# there's only a single one we prefer AVX2_256 SIMD instead.
#

${CXX} -O3 -mavx512f -std=c++11 \
-DGMX_IDENTIFY_AVX512_FMA_UNITS_STANDALONE=1 \
-DGMX_X86_GCC_INLINE_ASM=1 \
-DSIMD_AVX_512_CXX_SUPPORTED=1 \
-o ${PREFIX}/bin.AVX_512/identifyavx512fmaunits \
${SRC_DIR}/src/gromacs/hardware/identifyavx512fmaunits.cpp


# Create wrapper and activation scripts

if [ "${mpi}" = 'nompi' ] ; then
  gmx='gmx'
else
  gmx='gmx_mpi'
fi

mkdir -p "${PREFIX}/etc/conda/activate.d"
touch "${PREFIX}/bin/${gmx}"
chmod +x "${PREFIX}/bin/${gmx}"

{ cat <<EOF
#! /bin/sh

function _gromacs_bin_dir() {
  local arch
  arch='SSE2'
  case \$( grep -m1 '^flags' ) in
    *\ avx512f\ *)
      test -d "${PREFIX}/bin.AVX_512" && \
        "${PREFIX}/bin.AVX_512/identifyavx512fmaunits" | grep -q '2' && \
        arch='AVX_512'
    ;;
    *\ avx2\ *)
      test -d "${PREFIX}/bin.AVX2_256" && \
        arch='AVX2_256'
    ;;
    *\ avx\ *)
      test -d "${PREFIX}/bin.AVX_256" && \
        arch='AVX_256'
  esac
  printf '%s' "${PREFIX}/bin.\${arch}"
}

EOF
} | tee "${PREFIX}/bin/${gmx}" > "${PREFIX}/etc/conda/activate.d/gromacs_activate.sh"

cat >> "${PREFIX}/etc/conda/activate.d/gromacs_activate.sh" <<EOF
. "\$( _gromacs_bin_dir )/GMXRC" "\${@}"
EOF

cat >> "${PREFIX}/bin/${gmx}" <<EOF
exec "\$( _gromacs_bin_dir )/${gmx}" "\${@}"
EOF
