#!/bin/bash

# Info we do not use the Makefile provided by the tool because include the building of an third part tool (bamtools)
# that can be retrived already compiled from conda.
#

# without these lines, -lz can not be found
export CXXFLAGS="$CXXFLAGS -L${PREFIX}/lib -O3 -L./"
export LIBRARY_PATH=${PREFIX}/lib
export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include

# prepare lib installed from bamtools
cp ${BUILD_PREFIX}/lib/libbamtools.a .
cp -r ${BUILD_PREFIX}/include/bamtools/api/ .
for i in api/*.h;do sed -i.bak "s#api/##g" $i;done
cp -r ${BUILD_PREFIX}/include/bamtools/shared/ api/
for i in api/shared/*.h;do sed -i.bak "s#shared/##g" $i;done

# prepare bin folder
mkdir -p  "${PREFIX}/bin"
#now compile
${CXX} ${CXXFLAGS} bamaddrg.cpp -o ${PREFIX}/bin/bamaddrg -lbamtools -lz
# make it executable
chmod +x ${PREFIX}/bin/bamaddrg
