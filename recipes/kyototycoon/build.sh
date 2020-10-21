#!/bin/bash


# Remove gcc/g++ -ansi option to avoid the following error:
#    stdlib.h:513:15: error: expected '=', ',', ';', 'asm' or '__attribute__' before 'void'
#      static inline void* aligned_alloc (size_t al, size_t sz)
#

sed -i'' -e 's/-ansi//g' kyototycoon/configure kyotocabinet/configure

# Building Kyotocabinet and Kyototycoon
export CXXFLAGS="-no-pie"
make PREFIX=${PREFIX} CMDLIBS='-lkyotocabinet -llzo2 -llua -ldl -lz'
make install
