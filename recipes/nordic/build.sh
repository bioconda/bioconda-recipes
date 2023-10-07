#!/usr/bin/env bash

echo "Step #1"
pwd
cd ${SRC_DIR}"/MaBoSS-2.0/"
echo "Step #2"
ls
FILE=$(ls | grep "master*.tar.gz")
echo "Step #3"
echo $FILE
unzip $FILE
echo "Step #4"
ls
cd MaBoSS-env-2.0-master/engine/src
echo "Step #5"
ls
make install \
    CC="${CC}" \
    CXX="${CXX}" \
    CFLAGS="${CFLAGS}" \
    CXXFLAGS="${CXXFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    prefix="${PREFIX}"
"${PYTHON}" -m pip install bonesis maboss mpbn
"${PYTHON}" -m pip install --no-deps --no-build-isolation . -vvv