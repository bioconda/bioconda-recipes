#!/bin/bash
set -euxo pipefail

# Environment setup
export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -std=c++17 -O3 ${INCLUDES}"
export LDFLAGS="${LDFLAGS} ${LIBPATH}"

# Supported SIMD levels in order of preference
AMD64_SIMD_LEVELS=(avx2 avx sse4.1 ssse3 sse3)

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

# Create the SIMD dispatch script
cat <<'EOF' >$PREFIX/bin/STAR
#!/bin/bash
cpu_flags=$(grep -oP 'flags\s+:\s+\K.*' /proc/cpuinfo | sort | uniq | tr '\n' ' ')

if [[ $cpu_flags == *"avx2"* ]]; then
    exec "$PREFIX/bin/STAR-avx2" "$@"
elif [[ $cpu_flags == *"avx"* ]]; then
    exec "$PREFIX/bin/STAR-avx" "$@"
elif [[ $cpu_flags == *"sse4.1"* || $cpu_flags == *"sse4_1"* ]]; then
    exec "$PREFIX/bin/STAR-sse4.1" "$@"
elif [[ $cpu_flags == *"ssse3"* ]]; then
    exec "$PREFIX/bin/STAR-ssse3" "$@"
elif [[ $cpu_flags == *"sse3"* ]]; then
    exec "$PREFIX/bin/STAR-sse3" "$@"
else
    echo "No suitable SIMD binary found." >&2
    exit 1
fi
EOF
chmod +x $PREFIX/bin/STAR

# Plain build as fallback
make -j"${CPU_COUNT}" CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" STAR STARlong
mv STAR $PREFIX/bin/STAR-plain
mv STARlong $PREFIX/bin/STARlong-plain

echo "Build completed successfully."
