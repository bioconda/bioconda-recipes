#!/bin/bash

# Fix macOS linker failure due to libc++ deployment target mismatch and -fatal_warnings
if [[ "${target_platform}" == osx-* ]]; then
    export MACOSX_DEPLOYMENT_TARGET="11.3"
    export CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=11.3"
    export LDFLAGS="${LDFLAGS} -mmacosx-version-min=11.3"
    export LDFLAGS="${LDFLAGS//-Wl,-fatal_warnings/}"
fi

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -D_LIBCPP_DISABLE_AVAILABILITY"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -Wno-deprecated-declarations"

sed -i.bak 's|VERSION 3.1.0|VERSION 3.5|' subprojects/cpptoml/CMakeLists.txt
sed -i.bak 's|VERSION 2.8.11|VERSION 3.5|' subprojects/sdsl-lite/CMakeLists.txt
rm -rf subprojects/cpptoml/*.bak
rm -rf subprojects/sdsl-lite/*.bak

sed -i.bak '/find_package(LIBCXX/d' subprojects/cpptoml/CMakeLists.txt
sed -i.bak '/set_libcxx_required_flags/d' subprojects/cpptoml/CMakeLists.txt

CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" meson setup --buildtype release \
    --prefix "${PREFIX}" --strip -Db_coverage=false build/

cd build

ninja install -v -j"${CPU_COUNT}"

# python wrappers:
${PYTHON} -m pip install "${PREFIX}/lib/btllib/python" --no-deps --no-build-isolation --no-cache-dir -vvv
