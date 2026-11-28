#!/bin/bash
set -euxo pipefail

# gPlace 0.1.0's setup.py runs the C compiler as `gcc`: make that command the conda compiler.
# (GSL's configure, run by setup.py, takes the compiler from $CC, the same compiler.)
mkdir -p "${SRC_DIR}/conda-cc"
printf '#!/bin/bash\nexec "%s" "$@"\n' "${CC}" > "${SRC_DIR}/conda-cc/gcc"
chmod +x "${SRC_DIR}/conda-cc/gcc"
export PATH="${SRC_DIR}/conda-cc:${PATH}"

# conda's osx-arm64 compiler sets host_alias/build_alias to arm64-apple-darwin20.0.0, a name GSL 1.16's
# config.sub (2013) rejects. Unset, GSL's configure takes the aarch64-apple-darwin that setup.py passes,
# as in a pip install on a Mac; the tools stay conda's ($CC, $AR, $RANLIB, ...).
if [[ "${target_platform}" == "osx-arm64" ]]; then
  unset host_alias build_alias
fi

export GPLACE_GSL_TARBALL="${SRC_DIR}/gsl/gsl-1.16.tar.gz.packed"
export GPLACE_BUILD_DIR="${SRC_DIR}/gplace-build"
export GPLACE_BUILD_JOBS="${CPU_COUNT}"

"${PYTHON}" -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv
