#! /bin/bash
make CC="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"
install -d "${PREFIX}/bin"
install fqz_comp "${PREFIX}/bin/"
