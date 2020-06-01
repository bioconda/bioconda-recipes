#!/bin/sh

cd source
sed -i.bak "s,add_subdirectory(thirdparty/boost-cmake-1.67.0),find_package(Boost REQUIRED COMPONENTS system program_options filesystem),g" CMakeLists.txt
sed -i.bak "s,include_directories(thirdparty),#include_directories(thirdparty),g" CMakeLists.txt
sed -i.bak "/ExternalProject_Add/,/)/d" io/CMakeLists.txt
sed -i.bak "s,add_library(htslib IMPORTED),add_library(htslib IMPORTED)\ninclude_directories(${PREFIX}/include)\nlink_directories(${PREFIX}/lib),g" io/CMakeLists.txt
sed -i.bak "s,add_dependencies(htslib htslib_project),,g" io/CMakeLists.txt
sed -i.bak "/target_include_directories/,/)/d" io/CMakeLists.txt
sed -i.bak "/set_property(TARGET htslib/,/)/d" io/CMakeLists.txt

sed -i.bak "s,thirdparty/spdlog/spdlog.h,spdlog/spdlog.h,g" merge/MergeWorkflow.cpp
sed -i.bak "s,thirdparty/spdlog/spdlog.h,spdlog/spdlog.h,g" profile/ProfileWorkflow.cpp
sed -i.bak "s,thirdparty/spdlog/spdlog.h,spdlog/spdlog.h,g" app/ExpansionHunterDenovo.cpp

cd ..

mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ../source

sed -i.bak "s,htslib-NOTFOUND,${PREFIX}/lib/libhts.so,g" CMakeFiles/ExpansionHunterDenovo.dir/link.txt
sed -i.bak "s,htslib-NOTFOUND,${PREFIX}/lib/libhts.so,g" CMakeFiles/ExpansionHunterDenovo.dir/build.make

make
cp ExpansionHunterDenovo $PREFIX/bin/ExpansionHunterDenovo
