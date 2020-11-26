#!/bin/bash
sed -i.bak 's/Boost_USE_STATIC_LIBS OFF/Boost_USE_STATIC_LIBS ON/' CMakeLists.txt
mkdir -p extlibs/flat_hash_map && extlibs/flat_hash_map
wget https://raw.githubusercontent.com/skarupke/flat_hash_map/master/bytell_hash_map.hpp
wget https://raw.githubusercontent.com/skarupke/flat_hash_map/master/flat_hash_map.hpp
wget https://raw.githubusercontent.com/skarupke/flat_hash_map/master/unordered_map.hpp
popd
mkdir build && pushd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make 
popd
mkdir -p $PREFIX/bin
cp ./bin/artic-tools ${PREFIX}/bin/
