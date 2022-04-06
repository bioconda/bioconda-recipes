
#!/bin/bash

make CC="${CXX}" LINK="${CXX}" SWITCHES="${CPPFLAGS} ${CXXFLAGS} -std=c++14 ${LDFLAGS}"
make install PREFIX="${PREFIX}/bin"