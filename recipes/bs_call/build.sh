#!/bin/bash

sed -i.bak '
    @^GSL_LIB = -L/apps/GSL/2.4/lib/@ s@= -L.*@= '$PREFIX'/lib@
    @^GSL_INC = -I/apps/GSL/2.4/include/@ s@= -I.*@'$PREFIX'/include@
  ' Gsl.mk

make all
mkdir -p $PREFIX/bin
cp bin/bs_call $PREFIX/bin
cp bin/dbSNP_idx $PREFIX/bin
