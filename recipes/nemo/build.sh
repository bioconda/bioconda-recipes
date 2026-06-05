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

make install BIN_INSTALL="$PREFIX/bin/" LIB_INSTALL="$PREFIX/lib/"

# The Makefile installs a version-stamped binary (nemo<MAJOR>.<MINOR>.<REV>);
# expose it under the package's command name.
# mv "${PREFIX}/bin/nemo2.4.0" "${PREFIX}/bin/nemo"
