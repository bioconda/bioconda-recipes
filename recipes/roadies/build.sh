#!/bin/bash
set -euo pipefail

mkdir -p $PREFIX/ROADIES

# libpll: vendored via source:
if [[ ! -f "$PREFIX/lib/libpll.so" ]]; then
    pushd libpll-src
    ./autogen.sh
    ./configure --prefix="$PREFIX"
    make -j"${CPU_COUNT}" || make -j"${CPU_COUNT}"
    make install
    popd
fi

# MLIPPER: rebuild from source 
pushd MLIPPER
make clean || true
make CUDA_HOME="${BUILD_PREFIX}/targets/x86_64-linux" \
     NVCC="${BUILD_PREFIX}/bin/nvcc" \
     CXX="${CXX}" \
     PLL_INC_DIR="${PREFIX}/include" \
     PLL_LIB_DIR="${PREFIX}/lib" \
     -j"${CPU_COUNT}"
popd

# TWILIGHT: vendor-built from source.
if [[ ! -f "TWILIGHT/bin/twilight" ]]; then
    if [[ ! -d "TWILIGHT" ]]; then
        git clone --depth 1 https://github.com/TurakhiaLab/TWILIGHT.git
    fi
    sed -i 's/-march=native/-march=x86-64-v3/g' TWILIGHT/CMakeLists.txt
    pushd TWILIGHT
    CMAKE_WRAP_DIR="$(mktemp -d)"
    REAL_CMAKE="$(command -v cmake)"
    cat > "${CMAKE_WRAP_DIR}/cmake" <<EOF
#!/bin/bash
if [[ "\$1" == --* ]]; then
    exec "${REAL_CMAKE}" "\$@"
else
    exec "${REAL_CMAKE}" -DCMAKE_CUDA_COMPILER="${BUILD_PREFIX}/bin/nvcc" -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DTBB_TEST=OFF "\$@"
fi
EOF
    chmod +x "${CMAKE_WRAP_DIR}/cmake"
    cat > "${CMAKE_WRAP_DIR}/dpkg" <<'EOF'
#!/bin/bash
exit 1
EOF
    chmod +x "${CMAKE_WRAP_DIR}/dpkg"
    PATH="${CMAKE_WRAP_DIR}:${PATH}" bash install/buildTWILIGHT.sh cuda
    rm -rf "${CMAKE_WRAP_DIR}"
    popd
fi
test -f "TWILIGHT/bin/twilight" || { echo "ERROR: TWILIGHT build failed - TWILIGHT/bin/twilight not produced" >&2; exit 1; }

# sampling helper
if [[ ! -d "workflow/scripts/sampling/build" ]]; then
    cd workflow/scripts/sampling
    mkdir -p build
    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX="${PREFIX}"
    make -j"${CPU_COUNT}"
    cd ../../../..
fi

cp -rf * ${PREFIX}/ROADIES

# libpll-src is build-time-only; dropping it from the installed copy
rm -rf "${PREFIX}/ROADIES/libpll-src"
