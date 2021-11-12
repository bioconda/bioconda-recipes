#!/bin/bash

cd c/
make HTSLIB_INCDIR=$PREFIX/include HTSLIB_LIBDIR=$PREFIX/lib
make install
