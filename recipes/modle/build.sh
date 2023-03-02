#!/bin/bash

export CONAN_V2=1
export CONAN_REVISIONS_ENABLED=1
export CONAN_NON_INTERACTIVE=1

export CMAKE_BUILD_PARALLEL_LEVEL=${CPU_COUNT}
export CTEST_PARALLEL_LEVEL=${CPU_COUNT}

if [[ ${DEBUG_C} == yes ]]; then
  CMAKE_BUILD_TYPE=Debug
else
  CMAKE_BUILD_TYPE=Release
fi

scratch=$(mktemp -d)
export CONAN_USER_HOME="$scratch/conan"

trap "rm -rf '$scratch'" EXIT

declare -a CMAKE_PLATFORM_FLAGS
if [[ ${HOST} =~ .*darwin.* ]]; then
  export MACOSX_DEPLOYMENT_TARGET=10.15  # Required to use std::filesystem
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_OSX_SYSROOT="${CONDA_BUILD_SYSROOT}")
else
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake")

  # Building b2 with Conan usually fails when using generic cc/c++ compiler wrappers/links
  printf '[requires]\nb2/4.9.2\n' > "$scratch/conanfile.txt"

  TMPBIN="$scratch/bin"
  mkdir "$TMPBIN"

  ln -sf "$CC" "$TMPBIN/gcc"
  ln -sf "$CXX" "$TMPBIN/g++"

  export PATH="$TMPBIN:$PATH"
  export CC="$TMPBIN/gcc"
  export CXX="$TMPBIN/g++"

  conan install "$scratch/conanfile.txt" -s compiler=gcc --build=b2/4.9.2
fi

# https://docs.conda.io/projects/conda-build/en/stable/user-guide/environment-variables.html#environment-variables-set-during-the-build-process
mkdir build
cmake -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE" \
      -DENABLE_DEVELOPER_MODE=OFF            \
      -DMODLE_ENABLE_TESTING=ON              \
      -DGIT_RETRIEVED_STATE=true             \
      -DGIT_TAG="v${PKG_VERSION#v}"          \
      -DGIT_IS_DIRTY=false                   \
      -DGIT_HEAD_SHA1="$PKG_HASH"            \
      -DGIT_DESCRIBE="$PKG_BUILD_STRING"     \
      -DCMAKE_INSTALL_PREFIX="$PREFIX"       \
      -DCMAKE_C_COMPILER="$CC"               \
      -DCMAKE_CXX_COMPILER="$CXX"            \
      "${CMAKE_PLATFORM_FLAGS[@]}"           \
      -B build/                              \
      -S .

cmake --build build/

ctest --test-dir build/   \
      --schedule-random   \
      --output-on-failure \
      --no-tests=error    \
      --timeout 100

cmake --install build/

"${PREFIX}/bin/modle" --version
"${PREFIX}/bin/modle_tools" --version
