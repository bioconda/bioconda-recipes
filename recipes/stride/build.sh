#!/bin/bash

sed -i 's/bool success = parser >> code;/parser >> code; bool success = !parser.fail();/g' Util/StdAlnTools.cpp
sed -i.bak 's|m_fileHandle!=NULL|m_fileHandle.is_open()|'   StringGraph/SGVisitors.h
sed -i.bak 's|m_fileHandle!=NULL|m_fileHandle.is_open()|'   StringGraph/SGVisitors.cpp
find . -name "STCommon.h" -exec sed -i 's/~0 << POS_BITS/~0ULL << POS_BITS/g' {} \;


#        sed -i '1i#include <cmath>' "$file"
#    fi
#    if ! grep -q "#include.*cstdlib" "$file"; then
#        sed -i '1i#include <cstdlib>' "$file"
#    fi
#done
sed -i 's#m_overflow.insert(std::make_pair<size_t, OverflowStorage>(i, c))#m_overflow.insert(std::make_pair(i, c))#g' SuffixTools/SparseGapArray.h
sed -i "34c typedef std::hash<std::string> StringHasher;" StriDe/overlap.cpp 
#sed -i "236c  LIBS = -lz  -lpthread" StriDe/Makefile 
export CXXFLAGS=" -O2 -fPIC -fpermissive -Wno-error -Wno-deprecated-declarations -Wno-unused-result -fpermissive -std=c++11 -D_GLIBCXX_USE_CXX11_ABI=0  ${CXXFLAGS} "
export CFLAGS="-O2 -fPIC ${CFLAGS}"
export LDFLAGS="-Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib "

sed -i "12a # include <string>" Util/HashMap.h 

./autogen.sh
./configure --prefix=$PREFIX --with-sparsehash=$PREFIX  --with-zlib=$PREFIX
sed -i "236c  LIBS = -L/usr/lib64 -lz  -lpthread" StriDe/Makefile
make CFLAGS="${CFLAGS}" CXXFLAGS=" -fopenmp ${CXXFLAGS}" AM_CXXFLAGS='' 
make install
