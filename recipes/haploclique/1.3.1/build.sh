#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

if [[ `c++ -dumpversion` == 4.8.* ]]; then
    echo 'GCC version 4.8.x detected, forcing switch of regex engine from C++11 to Boost'
    export USE_BOOST_REGEX='-DUSE_BOOST_REGEX=1'
fi

sed -i '1i#include <stdexcept>' external/docopt.cpp/docopt_value.h
sed -i '1i#include <stdexcept>' external/docopt.cpp/docopt.h

if [[ `uname -s` == "Darwin" ]]; then
    export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
    export CONFIG_ARGS=""
fi

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_COMPILER="${CXX}" \
      -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
      -DBOOST_ROOT="${PREFIX}" -DBoost_NO_SYSTEM_PATHS=ON "${USE_BOOST_REGEX}" \
      -DCMAKE_SKIP_BUILD_RPATH=FALSE -DCMAKE_BUILD_WITH_INSTALL_RPATH=TRUE \
      -DCMAKE_INSTALL_RPATH="${PREFIX}/lib64:${PREFIX}/lib:${PREFIX}/lib/bamtools" \
      -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE \
      -Wno-dev -Wno-deprecated --no-warn-unused-cli \
      "${CONFIG_ARGS}"

make -C build -j"${CPU_COUNT}"
make -C build install
