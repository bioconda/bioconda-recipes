#! /bin/bash
mkdir -p ${PREFIX}/bin
make CFLAGS="$CFLAGS" CPPFLAGS="$CPPFLAGS" prefix=$PREFIX CC=$CC CXX=$CXX install-all
