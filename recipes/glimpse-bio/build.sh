#!/bin/bash

# Build the binaries
make	\
	-j	4	\
	CC="$CC	-std=c++11"	\
	DYN_LIBS="-lz	-lpthread	-lbz2	-llzma	-lcurl	-lhts	-ldeflate"	\
	CXXFLAG=${PREFIX}/lib	\
	HTSLIB_INC=${PREFIX}/lib	\
	HTSLIB_LIB=${PREFIX}/lib/libhts.a	\
	BOOST_LIB_IO=${PREFIX}/lib/libboost_iostreams.a	\
	BOOST_LIB_PO=${PREFIX}/lib/libboost_program_options.a	\
	;

#	Install	the	binaries
install	./phase/bin/GLIMPSE_phase
install	./ligate/bin/GLIMPSE_ligate
install	./chunk/bin/GLIMPSE_chunk
install	./sample/bin/GLIMPSE_sample
install	./snparray/bin/GLIMPSE_snparray
install	./concordance/bin/GLIMPSE_concordance
