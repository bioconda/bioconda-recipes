#!/bin/bash
mkdir -p $PREFIX/bin
cd src
echo "#define ClonalFrameML_GITRevision \"v${PKG_VERSION}\"" > version.h
make CC="${CXX} ${CXXFLAGS} ${CPPFLAGS}" LDFLAGS="${LDFLAGS}"
cp ClonalFrameML $PREFIX/bin
