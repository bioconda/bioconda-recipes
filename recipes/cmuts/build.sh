#!/bin/bash
set -exo pipefail

# === Diagnostics ===
echo "=== conda build.sh diagnostics ==="
echo "PREFIX=${PREFIX}"
echo "BUILD_PREFIX=${BUILD_PREFIX:-unset}"
echo "SRC_DIR=${SRC_DIR:-unset}"
echo "PKG_VERSION=${PKG_VERSION}"
echo "PYTHON=${PYTHON}"
echo "CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH:-unset}"
echo "uname -m: $(uname -m)"
echo "uname -s: $(uname -s)"

# Verify host prefix has expected libraries
for lib in hts hdf5 z; do
    found=$(find "${PREFIX}/lib" -name "lib${lib}.*" -print -quit 2>/dev/null || true)
    if [[ -z "$found" ]]; then
        echo "WARNING: lib${lib} not found in ${PREFIX}/lib"
        ls "${PREFIX}/lib"/ | head -20
    else
        echo "OK: found ${found}"
    fi
done

# Verify htslib headers exist
if [[ -f "${PREFIX}/include/htslib/hts.h" ]]; then
    echo "OK: htslib/hts.h found in ${PREFIX}/include"
else
    echo "ERROR: htslib/hts.h NOT found in ${PREFIX}/include"
    ls "${PREFIX}/include/" 2>/dev/null | head -20
    exit 1
fi

# === Setup ===

# Ensure CMake finds libraries in the conda host prefix
export CMAKE_PREFIX_PATH="${PREFIX}"

# Write version file (setuptools-scm fallback since no .git in tarball)
echo "${PKG_VERSION}" > VERSION

# Fetch htscodecs submodule (not included in GitHub release tarballs)
# NOTE: Update this commit hash when bumping the htscodecs submodule
if [[ ! -f htscodecs/htscodecs/htscodecs.h ]]; then
    rmdir htscodecs 2>/dev/null || true
    git clone https://github.com/samtools/htscodecs htscodecs
    git -C htscodecs checkout 877e6051937f85c6e5f97b70d9b6c8ab887ce81e
fi

# === Build ===

# Clean stale build artifacts (conda-build reruns for multiple Python variants,
# each with a different $PREFIX — stale CMake caches cause find_library failures)
rm -rf build
rm -rf htscodecs/build

# Build C++ binaries (htscodecs + cmake)
export HDF5_DIR="${PREFIX}"
./configure --build-only

# Verify binaries were produced
for bin in bin/cmuts-core bin/_cmuts-generate-tests; do
    if [[ ! -f "$bin" ]]; then
        echo "ERROR: $bin not produced by build"
        exit 1
    fi
done

# === Install ===

# Copy htscodecs lib into conda prefix so it's found at runtime
cp -a htscodecs/lib/libhtscodecs* "${PREFIX}/lib/"

# Install binaries and fix rpaths
install -d "${PREFIX}/bin"
install -m 755 bin/cmuts-core "${PREFIX}/bin/"
install -m 755 bin/_cmuts-generate-tests "${PREFIX}/bin/"

# Rewrite htscodecs rpath from build dir to prefix
if [[ "$(uname)" == "Darwin" ]]; then
    for bin in "${PREFIX}/bin/cmuts-core" "${PREFIX}/bin/_cmuts-generate-tests"; do
        old_path=$(otool -L "$bin" | grep libhtscodecs | awk '{print $1}')
        if [[ -n "$old_path" ]]; then
            install_name_tool -change \
                "$old_path" \
                "${PREFIX}/lib/libhtscodecs.2.dylib" \
                "$bin"
        fi
    done
else
    for bin in "${PREFIX}/bin/cmuts-core" "${PREFIX}/bin/_cmuts-generate-tests"; do
        patchelf --set-rpath "${PREFIX}/lib" "$bin"
    done
fi

# Install shell scripts
for script in src/scripts/cmuts src/scripts/cmuts-align src/scripts/cmuts-generate; do
    if [[ -f "$script" ]]; then
        install -m 755 "$script" "${PREFIX}/bin/"
    fi
done

# Install Python package
export SETUPTOOLS_SCM_PRETEND_VERSION="${PKG_VERSION}"
${PYTHON} -m pip install . --no-deps --no-build-isolation -vv

# === Post-install verification ===
echo "=== Installed files ==="
ls -la "${PREFIX}/bin/cmuts"* "${PREFIX}/bin/_cmuts"* 2>/dev/null || true
echo "=== Library dependencies ==="
if [[ "$(uname)" == "Darwin" ]]; then
    otool -L "${PREFIX}/bin/cmuts-core" || true
else
    ldd "${PREFIX}/bin/cmuts-core" || true
fi
