#!/bin/bash

export CPPLAGS="$CPPFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
set -euxo pipefail
sed -i '40i#include <cstdint>\n#include <iterator>' ./src/utils/fast-liftover.cpp
sed -i '22i#include <cstdint>\n#include <iterator>' ./src/analysis/hmr_rep.cpp
sed -i '22i#include <cstdint>\n#include <iterator>' ./src/smithlab_cpp/sam_record.hpp
sed -i '22i#include <cstdint>\n#include <iterator>\n#include <utility>' ./src/analysis/hmr.cpp
sed -i '53iusing std::begin;\nusing std::end;' ./src/analysis/hmr.cpp
sed -i '55istd::vector<uint32_t> reads_vector;' ./src/analysis/hmr.cpp
sed -i '56istd::vector<std::pair<double, double>> meth_vector;' ./src/analysis/hmr.cpp
sed -i 's/make_partial_meth(reads, meth)/make_partial_meth(reads_vector, meth_vector)/g' src/analysis/hmr.cpp

mkdir build && cd build
../configure --prefix ${PREFIX}
make
make install
