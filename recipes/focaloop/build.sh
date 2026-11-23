#!/usr/bin/env bash
set -euo pipefail

export FOCALOOP_PORTABLE_ISA=1
"${PYTHON}" -m pip install . --no-deps --no-build-isolation -vv

# Pre-compile portable C99/OpenMP kernels using conda-build's ${CC} (no runtime Python deps needed)
NATIVE_DIR="${PREFIX}/share/focaloop/native_cache"
mkdir -p "${NATIVE_DIR}"

EXT=".so"
OMP_FLAGS="-fopenmp"
if [[ "${target_platform:-}" == osx-* ]] || [[ "$(uname -s)" == "Darwin" ]]; then
  EXT=".dylib"
  OMP_FLAGS=""
fi

ISA_FLAGS=""
if [[ "${target_platform:-}" == *-64 ]] || [[ "$(uname -m)" == "x86_64" ]]; then
  ISA_FLAGS="-msse4.2 -mpopcnt"
fi

# GeneLoop C/OpenMP core binary + ORF scout shared library
"${CC}" ${CFLAGS:-} -O3 ${ISA_FLAGS} ${OMP_FLAGS} focaloop/geneloop/glcore/glcore.c -lm -lpthread ${LDFLAGS:-} -o "${NATIVE_DIR}/glcore"
"${CC}" ${CFLAGS:-} -O3 -shared -fPIC ${ISA_FLAGS} ${OMP_FLAGS} focaloop/geneloop/csrc/orf_scout.c -lm ${LDFLAGS:-} -o "${NATIVE_DIR}/liborf_scout${EXT}"

# VariationLoop C shared libraries
MV_DIR="focaloop/malariavar/native"
"${CC}" ${CFLAGS:-} -O3 -shared -fPIC ${ISA_FLAGS} ${OMP_FLAGS} -I "${MV_DIR}" "${MV_DIR}/pla_sieve.c" -lm ${LDFLAGS:-} -o "${NATIVE_DIR}/libpla_sieve${EXT}"
"${CC}" ${CFLAGS:-} -O3 -shared -fPIC ${ISA_FLAGS} ${OMP_FLAGS} -I "${MV_DIR}" "${MV_DIR}/dothash_sketch.c" -lm ${LDFLAGS:-} -o "${NATIVE_DIR}/libdothash${EXT}"
"${CC}" ${CFLAGS:-} -O3 -shared -fPIC ${ISA_FLAGS} -I "${MV_DIR}" "${MV_DIR}/island_pc_core.c" -lm ${LDFLAGS:-} -o "${NATIVE_DIR}/libisland_pc${EXT}"
"${CC}" ${CFLAGS:-} -O3 -shared -fPIC ${ISA_FLAGS} -I "${MV_DIR}" "${MV_DIR}/ust_kernel.c" -lm ${LDFLAGS:-} -o "${NATIVE_DIR}/libust${EXT}"
"${CC}" ${CFLAGS:-} -O3 -shared -fPIC ${ISA_FLAGS} -I "${MV_DIR}" "${MV_DIR}/varloop_core.c" -lm ${LDFLAGS:-} -o "${NATIVE_DIR}/varloop_core${EXT}"

# Export FOCALOOP_NATIVE_CACHE on environment activation so read-only BioContainers reuse prebuilt libs
mkdir -p "${PREFIX}/etc/conda/activate.d" "${PREFIX}/etc/conda/deactivate.d"
cat << 'EOF' > "${PREFIX}/etc/conda/activate.d/focaloop_env.sh"
export FOCALOOP_NATIVE_CACHE="${CONDA_PREFIX}/share/focaloop/native_cache"
export FOCALOOP_NATIVE_DIR="${CONDA_PREFIX}/share/focaloop/native_cache"
EOF
cat << 'EOF' > "${PREFIX}/etc/conda/deactivate.d/focaloop_env.sh"
unset FOCALOOP_NATIVE_CACHE
unset FOCALOOP_NATIVE_DIR
EOF
