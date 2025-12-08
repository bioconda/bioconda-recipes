#! /bin/bash
mkdir -p "${PREFIX}"/bin

make clean
make CFLAGS="${CFLAGS}" CPPFLAGS="${CPPFLAGS}" prefix="${PREFIX}" CC="${CC}" CXX="${CXX} -L${PREFIX}/lib" LDFLAGS+="-lz -lpthread ${LDFLAGS} -L${PREFIX}/lib"
mv ./ngsngs "${PREFIX}"/bin/

make --directory misc CFLAGS="${CFLAGS}" CPPFLAGS="${CPPFLAGS}" prefix="${PREFIX}" CC="${CC}" CXX="${CXX} -L${PREFIX}/lib" LDFLAGS+="-lz -lpthread ${LDFLAGS} -L${PREFIX}/lib"
mv ./misc/LenConvert  ./misc/MetaMisConvert  ./misc/MisConvert  ./misc/QualConvert  ./misc/RandRef  ./misc/RandVar  ./misc/VCFtoBED "${PREFIX}"/bin/
