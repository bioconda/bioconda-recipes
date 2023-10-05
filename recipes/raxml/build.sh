#!/usr/bin/env bash

case `uname` in
Darwin) SUF=.mac;;
Linux) SUF=.gcc;;
*) echo "Unknown OS"; exit 1;;
esac

case `uname -m` in
x86_64) OPTS=("" ".SSE3" ".AVX2");;
aarch64) OPTS=("" ".SSE3");;
*) echo "Unknown architecture"; exit 2;;
esac

mkdir -p $PREFIX/bin

for PTHREADS in "" .PTHREADS; do
  for OPT in ${OPTS[@]}; do
    echo "######## Building Flags opt=$OPT pthread=$PTHREADS os=$SUF ######"
    MAKEFILE=Makefile${OPT}${PTHREADS}
    if [ -e ${MAKEFILE}${SUF} ]; then
      MAKEFILE=${MAKEFILE}$SUF
    else
      MAKEFILE=${MAKEFILE}.gcc
    fi
    make -f ${MAKEFILE} CC=$CC
    mv raxmlHPC* $PREFIX/bin
    make -f ${MAKEFILE} clean
  done
done
