#!/bin/bash
set -e

mkdir -p ${PREFIX}/bin

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -O3 -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"
export CFLAGS="${CFLAGS} -O3"

mv zlib-1.3.1/*.c src/
mv zlib-1.3.1/*.h src/

cd src || exit 1
echo "0" > gitver.txt

OS=$(uname)
ARCH=$(uname -m)

if [[ "${OS}" == "Darwin" && "${ARCH}" == "x86_64" ]]; then
	cp -rf ${RECIPE_DIR}/vcxproj_make_osx.py .
 	chmod 0755 vcxproj_make_osx.py
	python ./vcxproj_make_osx.py --openmp --pthread --cppcompiler "${CXX}" --ccompiler "${CC}"
elif [[ "${OS}" == "Darwin" && "${ARCH}" == "arm64" ]]; then
 	cp -rfv ${RECIPE_DIR}/sse2neon.h ${SRC_DIR}/src
	cp -rf ${RECIPE_DIR}/vcxproj_make_osx.py .
	chmod 0755 vcxproj_make_osx.py
 	python ./vcxproj_make_osx.py --openmp --pthread --nonative --cppcompiler "${CXX}" --ccompiler "${CC}"
elif [[ "${OS}" == "Linux" && "${ARCH}" == "aarch64" ]]; then
	cp -rfv ${RECIPE_DIR}/sse2neon.h ${SRC_DIR}/src
 	cp -rf ${RECIPE_DIR}/vcxproj_make.py .
 	chmod 0755 vcxproj_make.py
  	python ./vcxproj_make.py --openmp --lrt --pthread --nonative --cppcompiler "${CXX}" --ccompiler "${CC}"
else
	cp -rf ${RECIPE_DIR}/vcxproj_make.py .
	chmod 0755 vcxproj_make.py
 	python ./vcxproj_make.py --openmp --lrt --pthread --cppcompiler "${CXX}" --ccompiler "${CC}"
fi

# Verify binary exists and is executable
if [[ ! -f ../bin/reseek ]]; then
	echo "Error: reseek binary not found"
 	exit 1
fi

install -v -m 0755 ../bin/reseek ${PREFIX}/bin
