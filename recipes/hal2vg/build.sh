#!/bin/bash
# Needs C++17 to compile. Hopefully this won't be needed in the future
sed -i.bak 's/c++11/c++17/g' deps/libbdsg-easy/deps/DYNAMIC/CMakeLists.txt
mkdir -p deps/libbdsg-easy/deps/libbdsg/bdsg/obj
mkdir -p deps/libbdsg-easy/deps/libbdsg/lib

make cpp="h5c++"
mkdir -p ${PREFIX}/bin
for exe in hal2vg clip-vg halRemoveDupes halMergeChroms halUnclip filter-paf-deletions count-vg-hap-cov ; do
    install -m 755 ${exe} ${PREFIX}/bin
done
