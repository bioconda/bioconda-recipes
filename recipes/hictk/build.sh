#!/bin/bash

export CONAN_NON_INTERACTIVE=1
export CMAKE_BUILD_PARALLEL_LEVEL="${CPU_COUNT}"
export CTEST_PARALLEL_LEVEL="${CPU_COUNT}"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ "${DEBUG_C}" == yes ]]; then
  CMAKE_BUILD_TYPE=Debug
else
  CMAKE_BUILD_TYPE=Release
fi

scratch=$(mktemp -d)
export CONAN_HOME="${scratch}/conan"

# shellcheck disable=SC2064
trap "rm -rf '${scratch}'" EXIT

CMAKE_PLATFORM_FLAGS=(
  -Wno-dev
  -Wno-deprecated
  --no-warn-unused-cli
)

if [[ "${OSTYPE}" =~ .*darwin.* ]]; then
  # https://conda-forge.org/docs/maintainer/knowledge_base/#newer-c-features-with-old-sdk
  export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
  CMAKE_PLATFORM_FLAGS+=(
    -DCMAKE_OSX_SYSROOT="${CONDA_BUILD_SYSROOT}"
    -DCMAKE_FIND_FRAMEWORK=NEVER
    -DCMAKE_FIND_APPBUNDLE=NEVER
  )
else
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake")
fi

# Remove unnecessary dependencies from conanfile.py
patch conanfile.py < "${RECIPE_DIR}/conanfile.py.patch"

conan profile detect

# Install header-only deps
conan install conanfile.py \
       -s build_type="${CMAKE_BUILD_TYPE}" \
       -s compiler.cppstd=17 \
       -o 'hictk/*:with_cli_tool_deps=False' \
       -o 'hictk/*:with_benchmark_deps=False' \
       -o 'hictk/*:with_arrow=False' \
       -o 'hictk/*:with_eigen=False' \
       -o 'hictk/*:with_telemetry_deps=False' \
       -o 'hictk/*:with_unit_testing_deps=False' \
       -o 'hictk/*:with_fuzzy_testing_deps=False' \
       --build="*" \
       --output-folder=cmake-prefix/

# Add bioconda suffix to hictk version
sed -i.bak 's/set(HICTK_PROJECT_VERSION_SUFFIX "")/set(HICTK_PROJECT_VERSION_SUFFIX "bioconda")/' CMakeLists.txt

CMAKE_PREFIX_PATH="${CMAKE_PREFIX_PATH}:${PWD}/cmake-prefix"

# https://docs.conda.io/projects/conda-build/en/stable/user-guide/environment-variables.html#environment-variables-set-during-the-build-process
cmake -DCMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE}"   \
      -DCMAKE_PREFIX_PATH="${CMAKE_PREFIX_PATH}" \
      -DCMAKE_SYSTEM_PROCESSOR="$(uname -m)"     \
      -DBUILD_SHARED_LIBS=ON                     \
      -DENABLE_DEVELOPER_MODE=OFF                \
      -DHICTK_ENABLE_TESTING=ON                  \
      -DHICTK_ENABLE_FUZZY_TESTING=OFF           \
      -DHICTK_BUILD_EXAMPLES=OFF                 \
      -DHICTK_BUILD_BENCHMARKS=OFF               \
      -DHICTK_WITH_ARROW=OFF                     \
      -DHICTK_WITH_EIGEN=OFF                     \
      -DHICTK_BUILD_TOOLS=ON                     \
      -DHICTK_ENABLE_GIT_VERSION_TRACKING=OFF    \
      -DCMAKE_INSTALL_PREFIX="${PREFIX}"         \
      -DCMAKE_C_COMPILER="${CC}"                 \
      -DCMAKE_CXX_COMPILER="${CXX}"              \
      "${CMAKE_PLATFORM_FLAGS[@]}"               \
      -B build/                                  \
      -S .

cmake --build build/

ctest --test-dir build/   \
      --output-on-failure \
      --no-tests=error    \
      --timeout 240

cmake --install build/ --component Runtime

"${PREFIX}/bin/hictk" --version
