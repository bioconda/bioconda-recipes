set -x

mkdir build
cd build

# https://manual.gromacs.org/current/install-guide/index.html
# https://manual.gromacs.org/documentation/2026-rc/dev-manual/build-system.html
cmake_args=(
    -DSHARED_LIBS_DEFAULT=ON
    -DBUILD_SHARED_LIBS=ON
    -DGMX_PREFER_STATIC_LIBS=NO
    -DGMX_BUILD_OWN_FFTW=OFF
    -DGMX_DEFAULT_SUFFIX=ON
    -DREGRESSIONTEST_DOWNLOAD=OFF
    -DCMAKE_PREFIX_PATH="${PREFIX}"
    -DCMAKE_INSTALL_PREFIX="${PREFIX}"
    -DCMAKE_INSTALL_BINDIR="bin/gromacs_mddb"
    -DCMAKE_INSTALL_LIBDIR="lib"
    -DGMX_VERSION_STRING_OF_FORK="conda-forge"
    -DGMXAPI=OFF
    -DGMX_INSTALL_LEGACY_API=OFF
    -DGMX_INSTALL_NBLIB_API=OFF
    -DGMX_USE_RDTSCP=OFF
    -DGMX_DEFAULT_SUFFIX=OFF
    -DGMX_BINARY_SUFFIX="_mddb"
    -DGMX_LIBS_SUFFIX="_mddb"
)
cmake .. "${cmake_args[@]}"
make -j ${CPU_COUNT}
#make check
make install


mkdir -p "${PREFIX}/etc/conda/activate.d"
mkdir -p "${PREFIX}/etc/conda/deactivate.d"

{ cat <<EOF
. "${PREFIX}/bin/gromacs_mddb/GMXRC" "${@}"
EOF
} > "${PREFIX}/etc/conda/activate.d/gromacs_mddb_activate.sh"

cp "${RECIPE_DIR}/gromacs_mddb_deactivate.sh" "${PREFIX}/etc/conda/deactivate.d/"