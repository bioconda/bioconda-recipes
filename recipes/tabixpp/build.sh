#!/bin/bash

export C_INCLUDE_PATH=$PREFIX/include
export CPLUS_INCLUDE_PATH=$PREFIX/include

export LDFLAGS="-L$PREFIX/lib -L\$(LIB_DIR) -lhts -lpthread -lz -lm -llzma -lbz2"
export INCLUDES="-I . -Ihtslib -I$PREFIX/include -I\$(INC_DIR) -L. "
export LIBPATH="-L. -Lhtslib -L$PREFIX/lib"
export CXXFLAGS="-O3 -D_FILE_OFFSET_BITS=64 -std=c++0x"

sed 's:htslib/libhts.a\:::g' Makefile
sed 's/cd htslib && $(MAKE) lib-static//g' Makefile

export HTS_HEADERS="$PREFIX/include/htslib/bgzf.h $PREFIX/include/htslib/tbx.h"
export HTS_LIB="$PREFIX/lib/libhts.a"

make 
cp tabix++ $PREFIX/bin


