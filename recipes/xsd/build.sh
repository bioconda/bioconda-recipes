#!/bin/bash

set -xe

# https://build2.org/install.xhtml#unix
wget https://download.build2.org/0.17.0/build2-install-0.17.0.sh

sh build2-install-0.17.0.sh --yes --trust yes --timeout 6000 --jobs ${CPU_COUNT} --cxx ${CXX} ${PREFIX}

# https://www.codesynthesis.com/products/xsd/doc/install-build2.xhtml#unix-build2
bpkg create -d xsd-conda-build cc     \
  config.cxx=${CXX}               \
  config.cc.coptions=${CXXFLAGS}    \
  config.bin.rpath=${PREFIX}/lib \
  config.install.root=${PREFIX}  \
  config.install.sudo=sudo

cd xsd-conda-build

bpkg build --trust-yes --jobs ${CPU_COUNT} xsd@https://pkg.cppget.org/1/beta ?sys:libxerces-c

ls -laR ${PREFIX}