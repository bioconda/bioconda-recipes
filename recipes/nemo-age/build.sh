#!/bin/bash
set -euo pipefail

# The package version is taken from the recipe at render time; src/version.h
# is the actual source of truth and decides the binary's name. If a tag was cut
# without bumping version.h (or vice versa) they disagree, and the package would
# ship a binary whose banner does not match its version. Fail here instead.
src_version="$(bash ./getVersion.sh)"
if [ "${src_version}" != "${PKG_VERSION}" ]; then
    echo "ERROR: src/version.h says ${src_version}, package version is ${PKG_VERSION}." >&2
    echo "       Bump src/version.h and re-tag, or fix the tag." >&2
    exit 1
fi

ARCH="$(uname -m)"

case "$ARCH" in
    aarch64) MARCH="-march=armv8-a"    ;;
    arm64)   MARCH="-march=armv8.4-a"  ;;
    x86_64)  MARCH="-march=x86-64-v3"  ;;
    *)       MARCH=""                  ;;
esac

# Get conda's compiler flags into the build by rewriting the Makefile's
# `C_OPTS=-fPIC` line in place. An environment assignment such as
# `C_OPTS="$CXXFLAGS" make` loses to the makefile's own `C_OPTS=` line, and the
# argument form `make C_OPTS=...` would also override the `C_OPTS += -DHAS_GSL`
# the GSL block appends. Patching the line keeps the `+=` accumulations intact.
# The Makefile's O_OPTS (-O3) come after these flags and take precedence.
sed -i.bak \
    "s|^C_OPTS=-fPIC\$|C_OPTS=-fPIC ${MARCH} -std=c++14 -Wno-narrowing ${CXXFLAGS} ${CPPFLAGS}|" \
    Makefile

# Give the linker conda's flags (rpath into $PREFIX/lib above all). The MAC_ARM
# and MAC_x86 blocks reset LD_OPTS outright, so patch those lines too.
sed -i.bak "s|^LD_OPTS=-lstdc++\$|LD_OPTS=-lstdc++ ${LDFLAGS}|" Makefile
sed -i.bak "s|^\( *LD_OPTS=-lstdc++ -L\$(GSL_PATH)lib .*\)\$|\1 ${LDFLAGS}|" Makefile

MAKE_ARGS=(GSL_PATH="${PREFIX}/" CC="${CXX}" SHELL="/bin/bash")

if [[ "$OSTYPE" == "darwin"* ]]; then
    case "$ARCH" in
        arm64|aarch64) MAKE_ARGS+=(MAC_ARM=1) ;;
        *)             MAKE_ARGS+=(MAC_x86=1) ;;
    esac
fi

make "${MAKE_ARGS[@]}" -j"${CPU_COUNT}"

# `make` emits a single version-stamped binary into bin/ (created by make), and
# on macOS the MAC_ARM / MAC_x86 flags suffix its name (nemoage<ver>-macARM).
# Install whatever was actually built, under the command name `nemoage`.
built="$(ls -1 bin/nemoage* | head -n1)"
mkdir -p "${PREFIX}/bin"
cp "${built}" "${PREFIX}/bin/nemoage"
