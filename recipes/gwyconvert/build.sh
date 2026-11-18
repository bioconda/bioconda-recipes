#!/bin/bash
# Build script of the conda recipe for Bioconda: https://bioconda.github.io
# Builds Gwyddion and gwyconvert into $PREFIX. The Gwyddion version check and
# the configure flags come from the wheel build's ci/ scripts, so both stay in step.
set -euxo pipefail

CI_DIR=gwyddionpy/gwyddionpy-converter/ci

# The Gwyddion tarball in meta.yaml must match the pin in pyproject.toml.
expected="$("${CI_DIR}/gwyddion-version.sh")"
if ! grep -q "^PACKAGE_VERSION='${expected}'" gwyddion/configure; then
  echo "meta.yaml Gwyddion source does not match the pyproject.toml pin ${expected}" >&2
  exit 1
fi

# Newer config.guess/config.sub, so configure knows osx-arm64 and linux-aarch64.
cp "${BUILD_PREFIX}"/share/gnuconfig/config.* gwyddion/

source "${CI_DIR}/gwyddion-configure-flags.sh"

# conda's -dead_strip_dylibs idrops libgwydraw, which libgwydgets needs at runtime.
export LDFLAGS="${LDFLAGS//-Wl,-dead_strip_dylibs/}"

cd gwyddion
# --build/--host are equal on a native build and turn on cross mode otherwise.
./configure --prefix="${PREFIX}" --build="${BUILD}" --host="${HOST}" \
  "${GWYDDION_CONFIGURE_FLAGS[@]}"
make -j"${CPU_COUNT}"
make install
cd ..

# Modules are found through the libdir compiled into libgwyddion
# ($PREFIX/lib/gwyddion); conda rewrites that prefix on install.
"${CC}" ${CFLAGS} ${CPPFLAGS} $(pkg-config --cflags gwyddion) \
  -o "${PREFIX}/bin/gwyconvert" gwyddionpy/gwyddionpy-converter/gwyconvert.c \
  ${LDFLAGS} $(pkg-config --libs gwyddion)
