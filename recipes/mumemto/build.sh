#!/bin/bash
set -xe

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"
export CMAKE_PREFIX_PATH="${PREFIX}${CMAKE_PREFIX_PATH:+:${CMAKE_PREFIX_PATH}}"

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/lib"
mkdir -p "${PREFIX}/include"
mkdir -p "${SP_DIR}/mumemto"
mkdir -p "${PREFIX}/share/licenses/${PKG_NAME}"

if [[ "$(uname -s)" == "Darwin" ]]; then
  export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
  export CONFIG_ARGS=""
fi

# Main project: CLI binaries + shared lib + CMake package (installed under build/install by top-level CMake).
cmake -S "${SRC_DIR}" -B "${SRC_DIR}/build" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_COMPILER="${CXX}" \
  -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
  -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
  -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
  -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=FALSE \
  -Wno-dev -Wno-deprecated --no-warn-unused-cli \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  ${CONFIG_ARGS}

cmake --build "${SRC_DIR}/build" --clean-first -j "${CPU_COUNT:-4}"
cmake --install "${SRC_DIR}/build"

INSTALL_ROOT="${SRC_DIR}/build/install"
if [[ ! -d "${INSTALL_ROOT}" ]]; then
  echo "Expected CMake install tree at ${INSTALL_ROOT}"
  exit 1
fi

# C/C++ SDK: shared library, headers, CMake package (Mumemto::mumemto, find_package).
shopt -s nullglob
libs=( "${INSTALL_ROOT}/lib"/libmumemto* )
if (( ${#libs[@]} )); then
  cp -a "${libs[@]}" "${PREFIX}/lib/"
fi
shopt -u nullglob

if [[ -d "${INSTALL_ROOT}/lib/cmake" ]]; then
  mkdir -p "${PREFIX}/lib/cmake"
  cp -a "${INSTALL_ROOT}/lib/cmake"/* "${PREFIX}/lib/cmake/"
fi

if [[ -d "${INSTALL_ROOT}/include" ]]; then
  mkdir -p "${PREFIX}/include"
  cp -a "${INSTALL_ROOT}/include"/* "${PREFIX}/include/"
fi

# CLI tools (same layout as prior bioconda recipe).
install -v -m 0755 \
  "${SRC_DIR}/build/mumemto_exec" \
  "${SRC_DIR}/build/compute_lengths" \
  "${SRC_DIR}/build/extract_mums" \
  "${SRC_DIR}/build/anchor_merge" \
  "${PREFIX}/bin"
install -v -m 0755 "${SRC_DIR}/mumemto/mumemto" "${PREFIX}/bin"

cp -f "${SRC_DIR}/LICENSE" "${PREFIX}/share/licenses/${PKG_NAME}/"

# Python: pybind11 extension + package __init__ (mum, mem, …); requires installed Mumemto CMake package in PREFIX.
cd "${SRC_DIR}/python_bindings"
"${PYTHON}" -m pip install . --no-deps --no-build-isolation -v
cd "${SRC_DIR}"

# Remaining pure-Python modules (utils, viz, …); keep bindings __init__.py (skip empty package __init__).
for f in "${SRC_DIR}/mumemto"/*.py; do
  [[ -f "${f}" ]] || continue
  base=$(basename "${f}")
  [[ "${base}" == "__init__.py" ]] && continue
  install -v -m 0644 "${f}" "${SP_DIR}/mumemto/"
done
