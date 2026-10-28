#!/bin/bash

mkdir -p "${PREFIX}/"{lib,include}
export JAVA_HOME="${PREFIX}/lib/jvm"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ `uname` == "Darwin" ]]; then
	cp -rf ${PREFIX}/lib/jvm/include/darwin/jni_md.h ${PREFIX}/lib/jvm/include/
else
	cp -rf ${PREFIX}/lib/jvm/include/linux/jni_md.h ${PREFIX}/lib/jvm/include/
fi

cd src
make CC="${CC}" CXX="${CXX}" \
	CFLAGS="${CFLAGS} ${LDFLAGS}" \
	CXXFLAGS="${CXXFLAGS} ${LDFLAGS}" -j"${CPU_COUNT}"
make java \
	CC="${CC}" CXX="${CXX}" \
	CFLAGS="${CFLAGS} ${LDFLAGS}" \
	CXXFLAGS="${CXXFLAGS} ${LDFLAGS}" -j"${CPU_COUNT}"

install -d "${PREFIX}/bin"
install -v -m 0755 \
	example_cpp \
	*.py* \
	ssw_test \
	ssw.jar \
	"${PREFIX}/bin"

cp -rf *.so "${PREFIX}/lib"
cp -rf *.h "${PREFIX}/include"
cp -rf ssw.c "${PREFIX}/include"
cp -rf ssw_cpp.cpp "${PREFIX}/include"
