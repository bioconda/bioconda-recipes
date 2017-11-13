#!/bin/bash

mkdir pout2mzidbuild && cd pout2mzidbuild
# fix error that affects v.0.3.03 but is solved in 0.4.0
sed -i '/stdio\.h/a \#include <iostream>' $SRC_DIR/version_config.h.in
cmake $SRC_DIR/CMakeLists.txt -B 

# replace xsdcxx command with xsd in cmake generated file
sed -i 's/xsdcxx/xsd/' CMakeFiles/xsdpout2mzidmllibrary.dir/build.make
make
mkdir -p $PREFIX/bin
mv pout2mzid $PREFIX/bin/
cd ..
