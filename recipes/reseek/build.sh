#!/bin/bash
set -e

mkdir -p ${PREFIX}/bin

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"

cd src || exit 1
echo "0" > gitver.txt

case `uname` in
    Linux)
	cp -rf ${RECIPE_DIR}/vcxproj_make.py .
	chmod 0755 vcxproj_make.py
	python ./vcxproj_make.py --openmp --lrt --pthread --std "c++17" --cppcompiler "${CXX}" --ccompiler "${CC}"
	;;
    Darwin)
	cp -rf ${RECIPE_DIR}/vcxproj_make_osx.py .
	chmod 0755 vcxproj_make_osx.py
	python ./vcxproj_make_osx.py --openmp --lrt --pthread --std "c++17" --cppcompiler "${CXX}" --ccompiler "${CC}"
	;;
    *)
	echo "Unknown uname '`uname`'" >&2
	exit 1
esac

# Verify binary exists and is executable
if [[ ! -f ../bin/reseek ]]; then
    echo "Error: reseek binary not found"
    exit 1
fi

install -v -m 0755 ../bin/reseek ${PREFIX}/bin