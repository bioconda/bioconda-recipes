#!/bin/bash

make \
	-j 4 \
	DYN_LIBS="-lz -lpthread -lbz2 -llzma -lcurl -lhts -ldeflate" \
	CXXFLAG=${PREFIX}/lib \
	HTSLIB_INC=${PREFIX}/lib \
	HTSLIB_LIB=${PREFIX}/lib/libhts.a \
	BOOST_LIB_IO=${PREFIX}/lib/libboost_iostreams.a \
	BOOST_LIB_PO=${PREFIX}/lib/libboost_program_options.a \
	;
