#!/bin/bash

case "${target_platform}" in osx-*) export MACOSX_DEPLOYMENT_TARGET=10.12 ; esac
#sed -i.bak 's/Boost_USE_STATIC_LIBS OFF/Boost_USE_STATIC_LIBS ON/' CMakeLists.txt

mkdir -p extlibs/flat_hash_map && pushd extlibs/flat_hash_map
curl -o bytell_hash_map.hpp https://raw.githubusercontent.com/skarupke/flat_hash_map/master/bytell_hash_map.hpp
curl -o flat_hash_map.hpp https://raw.githubusercontent.com/skarupke/flat_hash_map/master/flat_hash_map.hpp
curl -o unordered_map.hpp https://raw.githubusercontent.com/skarupke/flat_hash_map/master/unordered_map.hpp
popd

mkdir -p extlibs/PicoSHA2 && pushd extlibs/PicoSHA2
curl -o picosha2.h https://raw.githubusercontent.com/okdshin/PicoSHA2/master/picosha2.h
popd

mkdir build && pushd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make 
popd

mkdir -p $PREFIX/bin
cp ./bin/artic-tools ${PREFIX}/bin/
