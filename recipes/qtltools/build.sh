#!/bin/bash

sed -i'.bak' 's/CXX=/CXX?=/g' Makefile
sed -i'.bak' 's,BOOST_INC=,BOOST_INC=\$(PREFIX)/include,g' Makefile
sed -i'.bak' 's,BOOST_LIB=,BOOST_LIB=\$(PREFIX)/lib,g' Makefile
sed -i'.bak' 's,RMATH_INC=,RMATH_INC=\$(PREFIX)/lib/R/include/,g' Makefile
sed -i'.bak' 's,RMATH_LIB=,RMATH_LIB=\$(PREFIX)/lib/R/lib/,g' Makefile
sed -i'.bak' 's,HTSLD_INC=,HTSLD_INC=\$(PREFIX)/include,g' Makefile
sed -i'.bak' 's,HTSLD_LIB=,HTSLD_LIB=\$(PREFIX)/lib,g' Makefile

make

mkdir -p ${PREFIX}/bin

install -m775 bin/QTLtools ${PREFIX}/bin/
