#!/usr/bin/env bash
set -euo pipefail

export FOCALOOP_PORTABLE_ISA=1
"${PYTHON}" -m pip install . --no-deps --no-build-isolation -vv

# Pre-compile portable C99/OpenMP kernels into the installed package / shared cache
NATIVE_DIR="${PREFIX}/share/focaloop/native_cache"
mkdir -p "${NATIVE_DIR}"
export FOCALOOP_BUILD_NATIVE_DIR="${NATIVE_DIR}"
export FOCALOOP_NATIVE_CACHE="${NATIVE_DIR}"
"${PYTHON}" -c "from focaloop.galaxy_runners import prebuild_all_native_libs; print(prebuild_all_native_libs())"

# Export FOCALOOP_NATIVE_CACHE on environment activation so read-only containers reuse prebuilt libs
mkdir -p "${PREFIX}/etc/conda/activate.d" "${PREFIX}/etc/conda/deactivate.d"
cat << 'EOF' > "${PREFIX}/etc/conda/activate.d/focaloop_env.sh"
export FOCALOOP_NATIVE_CACHE="${CONDA_PREFIX}/share/focaloop/native_cache"
export FOCALOOP_NATIVE_DIR="${CONDA_PREFIX}/share/focaloop/native_cache"
EOF
cat << 'EOF' > "${PREFIX}/etc/conda/deactivate.d/focaloop_env.sh"
unset FOCALOOP_NATIVE_CACHE
unset FOCALOOP_NATIVE_DIR
EOF
