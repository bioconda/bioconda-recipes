set -x

mkdir build
cd build

cmake_args=(
    -DSHARED_LIBS_DEFAULT=ON
    -DBUILD_SHARED_LIBS=ON
    -DGMX_PREFER_STATIC_LIBS=NO
    -DGMX_BUILD_OWN_FFTW=OFF
    -DGMX_DEFAULT_SUFFIX=ON
    -DREGRESSIONTEST_DOWNLOAD=OFF
    -DCMAKE_PREFIX_PATH="${PREFIX}"
    -DCMAKE_INSTALL_PREFIX="${PREFIX}"
    -DCMAKE_INSTALL_BINDIR="bin"
    -DCMAKE_INSTALL_LIBDIR="lib"
    -DGMX_VERSION_STRING_OF_FORK="conda-forge"
    -DGMX_INSTALL_LEGACY_API=ON
    -DGMX_USE_RDTSCP=OFF
)
cmake .. "${cmake_args[@]}"
make -j ${CPU_COUNT}
#make check
make install


mkdir -p "${PREFIX}/etc/conda/activate.d"
mkdir -p "${PREFIX}/etc/conda/deactivate.d"

{ cat <<EOF
. "${PREFIX}/bin/GMXRC" "${@}"
EOF
} > "${PREFIX}/etc/conda/activate.d/gromacs_activate.sh"

cp "${RECIPE_DIR}/gromacs_deactivate.sh" "${PREFIX}/etc/conda/deactivate.d/"