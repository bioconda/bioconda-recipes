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
  export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
  export DYLD_FALLBACK_LIBRARY_PATH="${BUILD_PREFIX}/lib:${PREFIX}/lib${DYLD_FALLBACK_LIBRARY_PATH:+:${DYLD_FALLBACK_LIBRARY_PATH}}"
else
  export CONFIG_ARGS=""
fi

INSTALL_ROOT="${SRC_DIR}/build/install"

# Main project: CLI binaries + shared lib + CMake package (installed under build/install by top-level CMake).
# Conda CMAKE_ARGS already sets absolute CMAKE_AR/RANLIB (cctools). Do not override those with bare
# tool names — that breaks `ar` when linking libsdsl.a on CI ("Error running link command: no such file").
# CMAKE_ARGS also passes -DCMAKE_INSTALL_LIBDIR=lib as a PATH; CMake absolutizes it against SRC_DIR,
# so force STRING-typed relative install dirs after CMAKE_ARGS for find_package(Mumemto).
cmake -S "${SRC_DIR}" -B "${SRC_DIR}/build" \
  ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_COMPILER="${CXX}" \
  -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
  -DCMAKE_INSTALL_LIBDIR:STRING=lib \
  -DCMAKE_INSTALL_BINDIR:STRING=bin \
  -DCMAKE_INSTALL_INCLUDEDIR:STRING=include \
  -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
  -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
  -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=FALSE \
  -Wno-dev -Wno-deprecated --no-warn-unused-cli \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  ${CONFIG_ARGS}

cmake --build "${SRC_DIR}/build" --clean-first -j "${CPU_COUNT:-4}"
cmake --install "${SRC_DIR}/build"

if [[ ! -d "${INSTALL_ROOT}" ]]; then
  echo "Expected CMake install tree at ${INSTALL_ROOT}"
  exit 1
fi

# C/C++ SDK: shared library, headers, CMake package (Mumemto::mumemto, find_package).
# Prefer INSTALL_ROOT; also accept $SRC_DIR/lib in case an absolute libdir slipped through.
shopt -s nullglob
for libdir in "${INSTALL_ROOT}/lib" "${SRC_DIR}/lib"; do
  libs=( "${libdir}"/libmumemto* )
  if (( ${#libs[@]} )); then
    cp -a "${libs[@]}" "${PREFIX}/lib/"
  fi
done
shopt -u nullglob

for cmakedir in "${INSTALL_ROOT}/lib/cmake" "${SRC_DIR}/lib/cmake"; do
  if [[ -d "${cmakedir}/Mumemto" ]]; then
    mkdir -p "${PREFIX}/lib/cmake"
    cp -a "${cmakedir}"/* "${PREFIX}/lib/cmake/"
  fi
done

if [[ -d "${INSTALL_ROOT}/include" ]]; then
  mkdir -p "${PREFIX}/include"
  cp -a "${INSTALL_ROOT}/include"/* "${PREFIX}/include/"
fi

if [[ ! -f "${PREFIX}/lib/cmake/Mumemto/MumemtoConfig.cmake" ]]; then
  echo "MumemtoConfig.cmake was not installed into ${PREFIX}/lib/cmake/Mumemto" >&2
  echo "Searched under ${INSTALL_ROOT}/lib and ${SRC_DIR}/lib:" >&2
  find "${SRC_DIR}" -name 'MumemtoConfig.cmake' 2>/dev/null >&2 || true
  exit 1
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
# scikit-build-core ignores CMAKE_INSTALL_PREFIX from CMAKE_ARGS; Mumemto_DIR is passed through for find_package.
export CMAKE_ARGS="${CMAKE_ARGS} -DMumemto_DIR=${PREFIX}/lib/cmake/Mumemto"
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
