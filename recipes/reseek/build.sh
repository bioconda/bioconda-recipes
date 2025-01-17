#!/bin/bash
set -e

mkdir -p ${PREFIX}/bin

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

cd src || exit 1
echo "0" > gitver.txt

cp ${RECIPE_DIR}/vcxproj_make.py .
chmod +x vcxproj_make.py
./vcxproj_make.py --openmp --lrt --cppcompiler "${CXX}" --ccompiler "${CC}"

# Verify binary exists and is executable
if [ ! -f ../bin/reseek ]; then
    echo "Error: reseek binary not found"
    exit 1
fi

install -v -m 0755 ../bin/reseek ${PREFIX}/bin
