#!/bin/bash
set -e

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

mkdir -p "${PREFIX}/bin"

cd src || exit 1
echo "0" > gitver.txt

cp -f "${RECIPE_DIR}/vcxproj_make.py" .
chmod +rx vcxproj_make.py

OS=$(uname -s)
ARCH=$(uname -m)

if [[ "${ARCH}" == "arm64" ]]; then
	sed -i.bak 's|-march=x86-64-v3|-march=armv8.4-a|' vcxproj_make.py
	rm -rf *.bak
elif [[ "${ARCH}" == "aarch64" ]]; then
	sed -i.bak 's|-march=x86-64-v3|-march=armv8-a|' vcxproj_make.py
	rm -rf *.bak
fi

if [[ "${OS}" == "Darwin" ]]; then
	python ./vcxproj_make.py --openmp --pthread --cppcompiler "${CXX}" --ccompiler "${CC}" --nonative
elif [[ "${OS}" == "Linux" ]]; then
	python ./vcxproj_make.py --openmp --pthread --lrt --cppcompiler "${CXX}" --ccompiler "${CC}" --nonative
fi

# Verify binary exists and is executable
if [ ! -x ../bin/muscle ]; then
    echo "Error: muscle binary not found"
    exit 1
fi

install -v -m 0755 ../bin/muscle "${PREFIX}/bin"
