#!/bin/bash

rm -rf data/
# Build specifying CPP compiler and C compiler
# Use sed to replace 'make' with 'make CXX=${CXX} CC=${CC}'
# This is necessary because the Makefile does not respect the CXX and CC variables
# Create bin directory
mkdir bin
mkdir -p "${PREFIX}/bin"
mv utils/*.py ${PREFIX}/bin/

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

if [[ `uname` == "Darwin" ]]; then
  export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
  export CONFIG_ARGS=""
fi

sed -i.bak 's|VERSION 3.1.0 FATAL_ERROR|VERSION 3.5 FATAL_ERROR|' CMakeLists.txt
rm -rf *.bak

# Generate Makefile
cd bin
cmake -S .. -B . -DTINY=ON -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_CXX_COMPILER="${CXX}" \
  -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
  "${CONFIG_ARGS}"

# Build executables mutselomega and readmutselomega
make CXX="${GXX}" CC="${CC}" -j"${CPU_COUNT}" mutselomega readmutselomega
install -v -m 0755 mutselomega readmutselomega "${PREFIX}/bin"

# Build executables nodemutsel and readnodemutsel
make CXX="${GXX}" CC="${CC}" -j"${CPU_COUNT}" nodemutsel readnodemutsel
install -v -m 0755 nodemutsel readnodemutsel "${PREFIX}/bin"

# Build executables nodeomega and readnodeomega
make CXX="${GXX}" CC="${CC}" -j"${CPU_COUNT}" nodeomega readnodeomega
install -v -m 0755 nodeomega readnodeomega "${PREFIX}/bin"

# Build executables nodetraits and readnodetraits
make CXX="${GXX}" CC="${CC}" -j"${CPU_COUNT}" nodetraits readnodetraits
install -v -m 0755 nodetraits readnodetraits "${PREFIX}/bin"
