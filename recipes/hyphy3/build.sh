#!/bin/bash
set -ex

# Eigen 3.4.0 is vendored as a second source entry (eigen-src/) so the build
# needs no network: FetchContent picks it up via FETCHCONTENT_SOURCE_DIR_*.
# ccache refuses to cache TUs compiled against a PCH unless these sloppiness
# flags are set (documented requirement for -include pch headers).
export CCACHE_SLOPPINESS="pch_defines,time_macros"

cmake -S . -B build -G Ninja \
    ${CMAKE_ARGS} \
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
MEM_MB=$(awk '/MemAvailable/ {print int($2/1024)}' /proc/meminfo 2>/dev/null)
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
