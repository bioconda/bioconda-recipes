#!/bin/bash
set -eu -o pipefail

# fix autoconf
sed -i '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/autom4te
sed -i '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/autoheader
sed -i '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/autoreconf
sed -i '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/ifnames
sed -i '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/autoscan
sed -i '1 s|^.*$|#!/usr/bin/env perl|g' $PREFIX/bin/autoupdate

mkdir -p build
sed -i 's/Boost_USE_STATIC_LIBS ON/Boost_USE_STATIC_LIBS OFF/' CMakeLists.txt
cd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -DBOOST_ROOT=$PREFIX -DBoost_NO_SYSTEM_PATHS=ON -DBoost_DEBUG=ON ..
make install
