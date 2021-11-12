#!/bin/bash

make \
  CC="${CC}" CXX="${CXX}" \
  INCLUDES='-I./lib -I. -I./lib/Rmath' \
  CFLAGS="${CFLAGS}"'-pipe -std=c++0x $(OPTFLAG) $(INCLUDES) -D__STDC_LIMIT_MACROS -DPCRE2_CODE_UNIT_WIDTH=8'

mkdir -p $PREFIX/bin
cp vt $PREFIX/bin
