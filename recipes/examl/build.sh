#! /bin/bash
set -x
set -e

cd parser && make -f Makefile.SSE3.gcc && mv parse-examl ${PREFIX}/bin
cd ../examl && make -f Makefile.SSE3.gcc && mv examl ${PREFIX}/bin
rm -f *.o && make -f Makefile.AVX.gcc && mv examl-AVX ${PREFIX}/bin
rm -f *.o && make -f Makefile.OMP.AVX.gcc && mv examl-OMP-AVX ${PREFIX}/bin
