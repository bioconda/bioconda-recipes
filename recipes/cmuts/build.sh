#!/bin/bash
set -exo pipefail

# Ensure pkg-config finds .pc files for all host dependencies
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig:${PKG_CONFIG_PATH:-}"

# Write version file (setuptools-scm fallback since no .git in tarball)
echo "${PKG_VERSION}" > VERSION

# Fetch htscodecs submodule (not included in GitHub release tarballs)
# NOTE: Update this commit hash when bumping the htscodecs submodule
if [[ ! -f htscodecs/htscodecs/htscodecs.h ]]; then
    rmdir htscodecs 2>/dev/null || true
    git clone https://github.com/samtools/htscodecs htscodecs
    git -C htscodecs checkout 877e6051937f85c6e5f97b70d9b6c8ab887ce81e
fi

# Build C++ binaries (htscodecs + cmake)
export HDF5_DIR="${PREFIX}"
./configure --build-only

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
