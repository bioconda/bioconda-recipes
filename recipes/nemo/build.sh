#!/bin/bash
set -euo pipefail

# The package version is taken from NEMO_VERSION at render time; src/version.h
# is the actual source of truth and decides the binary's name. If a tag was cut
# without bumping version.h (or vice versa) they disagree, and the package would
# ship a binary whose name does not match its version. Fail here instead.
src_version="$(./getVersion.sh)"
if [ "${src_version}" != "${PKG_VERSION}" ]; then
    echo "ERROR: src/version.h says ${src_version}, package version is ${PKG_VERSION}." >&2
    echo "       Bump src/version.h and re-tag, or fix the tag." >&2
    exit 1
fi

# `bin/` is gitignored, so a fresh checkout does not carry it.
mkdir -p bin/

ARCH="$(uname -m)"

case "$ARCH" in
    aarch64) MARCH="-march=armv8-a"    ;;
    arm64)   MARCH="-march=armv8.4-a"  ;;
    x86_64)  MARCH="-march=x86-64-v3"  ;;
    *)       MARCH=""                  ;;
esac

# The Makefile hard-codes `C_OPTS=-fPIC -march=native`, which no CI builder can
# use, so rewrite that line in place.
#
# Note this is the only way to get conda's flags into the build. The obvious
# `C_OPTS="$CPPFLAGS $CXXFLAGS" make ...` is an *environment* assignment, and
# environment variables lose to a makefile's own `C_OPTS=` line -- so it is
# silently a no-op and conda's hardening/include flags never reach the compiler.
# (`make C_OPTS=...`, the argument form, would win, but it also overrides the
# `C_OPTS += -DHAS_GSL` the GSL block appends, and the build then fails outright
# in Uniform.h.) Patching the line keeps the `+=` accumulations intact.
sed -i.bak \
    "s|^C_OPTS=-fPIC -march=native\$|C_OPTS=-fPIC ${MARCH} -std=c++14 -Wno-narrowing ${CXXFLAGS} ${CPPFLAGS}|" \
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

# `make` emits a single version-stamped binary into bin/, and on macOS the
# MAC_ARM / MAC_x86 flags suffix its name (nemo<ver>-macARM). The Makefile's
# own `install` target recomputes BIN_NAME *without* those flags and so looks
# for a name that was never produced. Install whatever was actually built,
# under the canonical command name.
built="$(ls -1 bin/nemo* | head -n1)"
mkdir -p "${PREFIX}/bin"
cp "${built}" "${PREFIX}/bin/nemo${PKG_VERSION}"
