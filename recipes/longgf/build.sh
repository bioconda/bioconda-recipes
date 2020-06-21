#!/bin/bash

cd bin


rm -dr lib include
#$GXX -g -O3 -std=c++11 -I $PREFIX/include -L $PREFIX/lib -lhts -o LongGF _com_fun_.c _gtf_struct_.c get_gfFrombam.c
#$GXX -g -Wall -O3 -std=c++11 -I$PREFIX/include -L$PREFIX/lib -lhts -o LongGF _com_fun_.c _gtf_struct_.c get_gfFrombam.c
$GXX -O3 -std=c++11 -I$PREFIX/include -L$PREFIX/lib -lhts -o LongGF _com_fun_.c _gtf_struct_.c get_gfFrombam.c
#$GXX -g -O3 -std=c++11 $CFLAGS $LDFLAGS -lhts -o LongGF _com_fun_.c _gtf_struct_.c get_gfFrombam.c

cp LongGF $PREFIX/bin/


