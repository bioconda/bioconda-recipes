#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "${PREFIX}/bin"
# The release tarball is a git archive and does not ship the (gitignored) bin/
# output directory, so create it before building.
mkdir -p bin/


ARCH=$(uname -m)

case "$ARCH" in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
	;;
esac

# The Makefile hard-codes "-march=native"; replace it with portable,
# architecture-specific flags so the build is reproducible on CI.
case "$ARCH" in
    aarch64)
	sed -i.bak 's|-march=native|-O3 -std=c++14 -march=armv8-a -Wno-narrowing|' Makefile
	;;
    arm64)
	sed -i.bak 's|-march=native|-O3 -std=c++14 -march=armv8.4-a -Wno-narrowing|' Makefile
	;;
    x86_64)
	sed -i.bak 's|-march=native|-O3 -std=c++14 -march=x86-64-v3 -Wno-narrowing|' Makefile
	;;
esac

if [[ "$OSTYPE" == "darwin"* ]]; then
    
	case "$ARCH" in
        arm64|aarch64)
            # Apple Silicon (M1, M2, M3, etc.) -> ARM architecture
            C_OPTS="${CPPFLAGS} ${CXXFLAGS}" make GSL_PATH="$PREFIX/" CC="$CXX" SHELL="/bin/bash" MAC_ARM=1 -j"${CPU_COUNT}"
            ;;
        x86_64|i386)
            # Legacy Intel architecture (or generic x86 container build)
            C_OPTS="${CPPFLAGS} ${CXXFLAGS}" make GSL_PATH="$PREFIX/" CC="$CXX" SHELL="/bin/bash" MAC_x86=1 -j"${CPU_COUNT}"
            ;;
        *)
            # Fallback or error handling for unexpected architectures
            echo "Warning: Unknown macOS architecture detected ($ARCH). Using ARM fallback."
            C_OPTS="${CPPFLAGS} ${CXXFLAGS}" make GSL_PATH="$PREFIX/" CC="$CXX" SHELL="/bin/bash" MAC_ARM=1 -j"${CPU_COUNT}"
            ;;
    esac
else
	C_OPTS="${CPPFLAGS} ${CXXFLAGS}" make GSL_PATH="$PREFIX/" CC="$CXX" SHELL="/bin/bash" -j"${CPU_COUNT}"
fi

mkdir -p "${PREFIX}/bin"
# `make` builds a single version-stamped binary into bin/. On macOS the
# MAC_ARM / MAC_x86 flags suffix its name (e.g. nemo<ver>-macARM); the
# Makefile's `install` target recomputes BIN_NAME *without* those flags and
# looks for the unsuffixed name, which fails on osx-arm64. Install the binary
# that was actually produced, under the canonical command name (nemo<version>).
built="$(ls -1 bin/nemo* | head -n1)"
cp "${built}" "${PREFIX}/bin/nemo${PKG_VERSION}"
