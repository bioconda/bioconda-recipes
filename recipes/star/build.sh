#!/bin/bash
set -euxo pipefail

# Environment setup
export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -std=c++17 -O3 ${INCLUDES}"
export LDFLAGS="${LDFLAGS} ${LIBPATH}"

# Supported SIMD levels in order of preference (Linux only)
AMD64_SIMD_LEVELS=(avx2 avx sse4.1 ssse3 sse3)

# Build binaries based on the operating system
if [[ "$(uname)" == "Darwin" ]]; then
    echo "Building STAR for macOS"
    make -j"${CPU_COUNT}" CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" STAR STARlong
    mv STAR $PREFIX/bin/STAR
    mv STARlong $PREFIX/bin/STARlong
else
    echo "Building STAR for Linux with SIMD optimizations"

    # Function to check if the CPU supports a specific SIMD level
    function supports_simd {
        local simd_level=$1
        echo "int main(){}" | ${CXX} -x c++ -o /dev/null -m${simd_level} - &>/dev/null
        return $?
    }

    # Build for supported SIMD levels
    for SIMD in ${AMD64_SIMD_LEVELS[@]}; do
        if supports_simd $SIMD; then
            echo "Building STAR with SIMD level: $SIMD"
            make -j"${CPU_COUNT}" CXX="${CXX}" CXXFLAGSextra="-m$SIMD" CXXFLAGS="${CXXFLAGS}" STAR STARlong
            mv STAR $PREFIX/bin/STAR-$SIMD
            mv STARlong $PREFIX/bin/STARlong-$SIMD
        else
            echo "Skipping unsupported SIMD level: $SIMD"
        fi
    done

    # Build plain binary as fallback
    make -j"${CPU_COUNT}" CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" STAR STARlong
    mv STAR $PREFIX/bin/STAR-plain
    mv STARlong $PREFIX/bin/STARlong-plain

    # Install the dispatch script for Linux
    install -m 755 simd-dispatch.sh $PREFIX/bin/STAR
fi

echo "Build completed successfully."
