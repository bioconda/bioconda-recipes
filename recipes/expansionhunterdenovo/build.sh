#!/bin/bash

cd source
sed -i.bak "s,add_subdirectory(thirdparty/boost-cmake-1.67.0),find_package(Boost REQUIRED COMPONENTS system program_options filesystem),g" CMakeLists.txt
sed -i.bak "s,include_directories(thirdparty),#include_directories(thirdparty),g" CMakeLists.txt
sed -i.bak "12c\find_package(fmt REQUIRED)" CMakeLists.txt
sed -i.bak "31s/common region profileworkflow mergeworkflow)/common region profileworkflow mergeworkflow\n    fmt::fmt)/" CMakeLists.txt
sed -i.bak '40s/)$/ fmt::fmt)/' CMakeLists.txt
sed -i.bak "/ExternalProject_Add/,/)/d" io/CMakeLists.txt
sed -i.bak "s,add_library(htslib IMPORTED),add_library(htslib IMPORTED)\ninclude_directories(${PREFIX}/include)\nlink_directories(${PREFIX}/lib),g" io/CMakeLists.txt
sed -i.bak "s,add_dependencies(htslib htslib_project),,g" io/CMakeLists.txt
sed -i.bak "/target_include_directories/,/)/d" io/CMakeLists.txt
sed -i.bak "/set_property(TARGET htslib/,/)/d" io/CMakeLists.txt
rm -rf *.bak
rm -rf io/*.bak

sed -i.bak "s,thirdparty/spdlog/spdlog.h,spdlog/spdlog.h,g" merge/MergeWorkflow.cpp
sed -i.bak "s,thirdparty/spdlog/spdlog.h,spdlog/spdlog.h,g" profile/ProfileWorkflow.cpp
sed -i.bak "s,thirdparty/spdlog/spdlog.h,spdlog/spdlog.h,g" app/ExpansionHunterDenovo.cpp

cd ..

if [[ `uname -s` == "Darwin" ]]; then
  export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
  export CONFIG_ARGS=""
fi

cmake -S source -B build -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
  -Wno-dev -Wno-deprecated --no-warn-unused-cli \
  "${CONFIG_ARGS}"

sed -i.bak "s,htslib-NOTFOUND,${PREFIX}/lib/libhts.so,g" build/CMakeFiles/ExpansionHunterDenovo.dir/link.txt
sed -i.bak "s,htslib-NOTFOUND,${PREFIX}/lib/libhts.so,g" build/CMakeFiles/ExpansionHunterDenovo.dir/build.make

cmake --build build --clean-first -j "${CPU_COUNT}"
install -v -m 0755 build/ExpansionHunterDenovo "${PREFIX}/bin"
