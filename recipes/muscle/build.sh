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

OS=$(uname -s)

if [[ "${OS}" == "Darwin" ]]; then
	cp -rf ${RECIPE_DIR}/vcxproj_make_osx.py .
	chmod 0755 vcxproj_make_osx.py
	python ./vcxproj_make_osx.py --openmp --pthread --cppcompiler "${CXX}" --ccompiler "${CC}"
elif [[ "${OS}" == "Linux" ]]; then
	cp -rf ${RECIPE_DIR}/vcxproj_make.py .
	chmod 0755 vcxproj_make.py
	export LDFLAGS="${LDFLAGS} -static"
  	python ./vcxproj_make.py --openmp --pthread --lrt --cppcompiler "${CXX}" --ccompiler "${CC}"
fi

# Verify binary exists and is executable
if [[ ! -x ../bin/muscle ]]; then
	echo "Error: muscle binary not found"
	exit 1
fi

install -v -m 0755 ../bin/muscle ${PREFIX}/bin
