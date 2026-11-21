#!/bin/bash
set -ex

# Eigen 3.4.0 is vendored as a second source entry (eigen-src/) so the build
# needs no network: FetchContent picks it up via FETCHCONTENT_SOURCE_DIR_*.
# ccache refuses to cache TUs compiled against a PCH unless these sloppiness
# flags are set (documented requirement for -include pch headers).
export CCACHE_SLOPPINESS="pch_defines,time_macros"

# CMAKE_ARGS carries the conda toolchain tools as bare names
# (x86_64-conda-linux-gnu-ar etc., intended for PATH lookup). CMake always
# absolutizes a relative -D path against the source dir (verified identical
# on 3.28 and 4.4), producing e.g. $SRC_DIR/x86_64-conda-linux-gnu-ar ->
# "No such file or directory" (exit 127) at the archiver step. Re-resolve
# each tool through PATH so CMake sees absolute paths; the later -D wins.
cmake -S . -B build -G Ninja \
    ${CMAKE_ARGS} \
    -DCMAKE_AR="$(command -v "${AR}")" \
    -DCMAKE_RANLIB="$(command -v "${RANLIB}")" \
    -DCMAKE_LINKER="$(command -v "${LD}")" \
    -DCMAKE_STRIP="$(command -v "${STRIP}")" \
    -DCMAKE_C_COMPILER_AR="$(command -v "${GCC_AR:-${AR}}")" \
    -DCMAKE_CXX_COMPILER_AR="$(command -v "${GCC_AR:-${AR}}")" \
    -DCMAKE_C_COMPILER_RANLIB="$(command -v "${GCC_RANLIB:-${RANLIB}}")" \
    -DCMAKE_CXX_COMPILER_RANLIB="$(command -v "${GCC_RANLIB:-${RANLIB}}")" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DHYPHY3_BUILD_TESTS=OFF \
    -DFETCHCONTENT_SOURCE_DIR_EIGEN3="${SRC_DIR}/eigen-src" \
    -DPython3_EXECUTABLE="${PYTHON}"

# Several TUs (emitters, Eigen-heavy analyses, the PCH) peak at ~3G each, so
# parallelism scales with *available* memory at ~4G/job (measured -j4 peak:
# ~11.4G). This yields -j2 on bioconda's ~8.5G-free x86 builders (as before —
# the container has no memory cap and OOM kills just "stop responding") but
# -j3/-j4 on CircleCI's roomier arm64 executors, where the flat -j2 was
# blowing the 1h job deadline.
# /proc/meminfo is absent on macOS: awk's exit 2 would kill the script under
# errexit via the substitution, so guard it and let the fallback run.
MEM_MB=$(awk '/MemAvailable/ {print int($2/1024)}' /proc/meminfo 2>/dev/null) || true
if [ -z "${MEM_MB}" ]; then
    # macOS has no /proc; free+inactive vm_stat pages ≈ MemAvailable.
    PAGE_KB=$(( $(sysctl -n vm.pagesize) / 1024 ))
    MEM_MB=$(vm_stat | awk -v pkb="${PAGE_KB}" \
        '/Pages free/ {f=$3} /Pages inactive/ {i=$3} \
         END {print int((f+i)*pkb/1024)}')
fi
JOBS=$(( MEM_MB / 4096 ))
# Floor at the previous flat -j2 (peak ~6G, proven on the x86 builders) so
# hosts in the 4-8G free band don't regress to -j1.
MIN_JOBS=$(( CPU_COUNT < 2 ? CPU_COUNT : 2 ))
JOBS=$(( JOBS < MIN_JOBS ? MIN_JOBS : JOBS ))
JOBS=$(( JOBS > CPU_COUNT ? CPU_COUNT : JOBS ))
# Floor of 1: an unset/0 CPU_COUNT (or <1G free) would otherwise give -j0.
JOBS=$(( JOBS < 1 ? 1 : JOBS ))
ninja -C build -j"${JOBS}"

# Upstream install() puts all CLI binaries in bin/ and the _hyphy3 module
# in lib/ (SKBUILD branch puts it at the wheel root instead; not our case).
ninja -C build install

# Python module + wrapper -> site-packages.
install -d "${SP_DIR}"
mv "${PREFIX}"/lib/_hyphy3*.so "${SP_DIR}/"
cp -r python/hyphy3 "${SP_DIR}/"
# Do not ship build artifacts that landed next to the module.
rm -rf "${SP_DIR}/hyphy3/__pycache__" "${SP_DIR}/hyphy3/tests"
