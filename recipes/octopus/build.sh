#!/bin/bash
set -eu -o pipefail

cd build
# BOOST -- need up to date version compiled with gcc 7.2
wget http://dl.bintray.com/boostorg/release/1.65.0/source/boost_1_65_0.tar.gz
tar -xzpf boost_1_65_0.tar.gz
cd boost_1_65_0

export BOOST_BUILD_PATH=`pwd`
cat <<EOF > ./user-config.jam
using gcc : : ${CXX} ;
EOF

./bootstrap.sh --prefix=$PREFIX --without-libraries=python --without-libraries=wave --with-icu=${PREFIX}
./b2 \
  --debug-configuration \
  runtime-link=shared \
  link=static,shared \
  toolset=gcc \
  cxxflags="${CXXFLAGS}" \
  install
cd ..
# octopus
cmake  -DINSTALL_PREFIX=ON -DCMAKE_INSTALL_PREFIX=$PREFIX -DINSTALL_ROOT=ON -DCMAKE_BUILD_TYPE=Release ..
make install
