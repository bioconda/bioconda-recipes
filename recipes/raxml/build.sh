#!/bin/bash

case `uname` in
Darwin) SUF=.mac;;
Linux) SUF=.gcc;;
*) echo "Unknown architecture"; exit 1;;
esac

mkdir -p $PREFIX/bin

for PTHREADS in "" .PTHREADS; do
  for OPT in "" .SSE3 .AVX2; do
    echo "######## Building Flags opt=$OPT pthread=$PTHREADS os=$SUF ######"
    make -f Makefile${OPT}${PTHREADS}${SUF} CC=$CC
    mv raxmlHPC* $PREFIX/bin
    make -f Makefile${OPT}${PTHREADS}${SUF} clean
  done
done
