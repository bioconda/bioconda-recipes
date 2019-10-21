#!/bin/bash

sed -i'.bak' 's/CXX=/CXX?=/g' makefile
sed -i'.bak' 's/CXXFLAG=/CXXFLAG=\$(CXXFLAGS)/g' makefile
sed -i'.bak' 's/LDFLAG=/LDFLAG=\$(LDFLAGS) \${LIBPATH}/g' makefile
sed -i'.bak' 's,HTSLIB_LIB=\$(HOME)/Tools/htslib-1.9/libhts.a,HTSLIB_LIB=-lhts,' makefile
sed -i'.bak' 's,BOOST_LIB_IO=/usr/lib/x86_64-linux-gnu/libboost_iostreams.a,BOOST_LIB_IO=-lboost_iostreams,' makefile
sed -i'.bak' 's,BOOST_LIB_PO=/usr/lib/x86_64-linux-gnu/libboost_program_options.a,BOOST_LIB_PO=-lboost_program_options,' makefile

make

mkdir -p ${PREFIX}/bin

install -m775 bin/shapeit4 ${PREFIX}/bin/
