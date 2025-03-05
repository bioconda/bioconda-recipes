#!/bin/bash
set -e

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

mkdir -p ${PREFIX}/bin
cd src || exit 1
echo "0" > gitver.txt

cp -rf ${RECIPE_DIR}/vcxproj_make.py .
chmod 0755 vcxproj_make.py

OS=$(uname)
ARCH=$(uname -m)

if [[ "${OS}" == "Darwin" && "${ARCH}" == "x86_64" ]]; then
	python ./vcxproj_make.py --openmp --pthread --cppcompiler "${CXX}" --ccompiler "${CC}"
elif [[ "${OS}" == "Darwin" && "${ARCH}" == "arm64" ]]; then
 	#cp -rfv ${RECIPE_DIR}/sse2neon.h ${SRC_DIR}/src
 	python ./vcxproj_make.py --openmp --pthread --cppcompiler "${CXX}" --ccompiler "${CC}"
elif [[ "${OS}" == "Linux" && "${ARCH}" == "aarch64" ]]; then
	#cp -rfv ${RECIPE_DIR}/sse2neon.h ${SRC_DIR}/src
  	python ./vcxproj_make.py --openmp --lrt --pthread --cppcompiler "${CXX}" --ccompiler "${CC}"
else
 	python ./vcxproj_make.py --openmp --lrt --pthread --cppcompiler "${CXX}" --ccompiler "${CC}"
fi

# Verify binary exists and is executable
if [[ ! -x ../bin/muscle ]]; then
	echo "Error: muscle binary not found"
	exit 1
fi

install -v -m 0755 ../bin/muscle ${PREFIX}/bin
