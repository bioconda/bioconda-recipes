#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

mkdir -p $PREFIX/bin

sed -i.bak 's/-msse4.1/-march=sandybridge -Ofast/g' deps/spoa/CMakeLists.txt
sed -i.bak 's/-march=native/-march=sandybridge -Ofast/g' deps/spoa/CMakeLists.txt
sed -i.bak 's/-march=native/-march=sandybridge -Ofast/g' deps/abPOA/CMakeLists.txt
rm -rf deps/spoa/*.bak
rm -rf deps/abPOA/*.bak

cmake -H. -Bbuild -DCMAKE_POLICY_VERSION_MINIMUM="3.5" -DCMAKE_BUILD_TYPE=Generic -DEXTRA_FLAGS='-march=sandybridge -Ofast'
cmake --build build -j "${CPU_COUNT}"
install -v -m 0755 bin/* "${PREFIX}/bin"
