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

# MLIPPER: genuinely GPU-only, no CPU fallback at all - its own Makefile
# hard-errors ($(error No CUDA installation found...)) with nothing to catch
# it. Only built where a CUDA toolchain exists (linux; meta.yaml's
# cuda-nvcc/etc are # [linux]-only). workflow/scripts/placement.sh only
# requires MLIPPER's presence when gpu>0, so CPU-mode/macOS users never need
# it - the binary just isn't there for them.
if [[ "$(uname)" != "Darwin" ]]; then
    pushd MLIPPER
    make clean || true
    make CUDA_HOME="${BUILD_PREFIX}/targets/x86_64-linux" \
         NVCC="${BUILD_PREFIX}/bin/nvcc" \
         CXX="${CXX}" \
         PLL_INC_DIR="${PREFIX}/include" \
         PLL_LIB_DIR="${PREFIX}/lib" \
         -j"${CPU_COUNT}"
    popd
else
    echo "macOS build - skipping MLIPPER (GPU-only; no CUDA toolchain for macOS)."
    # MLIPPER/MLIPPER ships as a prebuilt Linux+CUDA binary in the source
    # tarball - remove it rather than let a foreign-platform binary leak
    # into a macOS package.
    rm -f MLIPPER/MLIPPER
fi

# TWILIGHT: unlike MLIPPER, genuinely CPU/GPU-capable and required
# unconditionally by placement mode - workflow/scripts/placement.sh checks
# for TWILIGHT/bin/twilight and exits with an error if it's missing
# regardless of the gpu flag (only MLIPPER's check there is gpu-gated). So
# this must be built on every platform, just differently per platform.
if [[ ! -f "TWILIGHT/bin/twilight" ]]; then
    if [[ ! -d "TWILIGHT" ]]; then
        git clone --depth 1 https://github.com/TurakhiaLab/TWILIGHT.git
    fi
    if [[ "$(uname)" == "Darwin" ]]; then
        # TWILIGHT's own install/buildTWILIGHT.sh hardcodes `brew --prefix
        # tbb` on Darwin - unusable in a Homebrew-free conda sandbox. Instead
        # mirror TWILIGHT's own official bioconda recipe's build.sh exactly
        # (proven: it's what actually produces their published osx-64/
        # osx-arm64 twilight packages) - a direct, portable cmake invocation,
        # CPU-only (no -DUSE_CUDA flag).
        pushd TWILIGHT
        cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
              -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="${CXX}" \
              -DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER \
              -Wno-dev -Wno-deprecated --no-warn-unused-cli
        cmake --build build --clean-first -j "${CPU_COUNT}"
        popd
    else
        # Linux: GPU-capable build (already verified working).
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
