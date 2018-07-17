#!/bin/bash

#export CPATH=$PREFIX/lib
#export CFLAGS="-I$PREFIX/include"
#export LDFLAGS="-L$PREFIX/lib"

#adding include and library paths in order to find bzip2
sed -i.bak '
    /^PATH_INCLUDE=/ s@$@ -I'$PREFIX'/include@
    /^PATH_LIB=/ s@$@ -L'$PREFIX'/lib@
  ' Makefile.mk.in

#not being able to ensure cuda compatible end system it is disabled
#to compile this section was lifted from a more recent version of the repository.
#TODO: clarify with developers that this is OK
#sed -i.bak 's@#include "resources/gem-cutter/gpu_interface.h"@#ifdef HAVE_CUDA\
##include "resources/gem-cutter/gpu_interface.h"\
##else\
##define GPU_BPM_ALIGN_PEQ_ALPHABET_SIZE     5\
##define GPU_BPM_ALIGN_PEQ_ENTRY_LENGTH      128\
##define GPU_BPM_ALIGN_PEQ_SUBENTRY_LENGTH   32\
##define GPU_BPM_ALIGN_PEQ_SUBENTRIES        (GPU_BPM_ALIGN_PEQ_ENTRY_LENGTH / UINT32_LENGTH)\
#\
##define GPU_BPM_FILTER_PEQ_ALPHABET_SIZE     5\
##define GPU_BPM_FILTER_PEQ_ENTRY_LENGTH      128\
##define GPU_BPM_FILTER_PEQ_SUBENTRY_LENGTH   32\
##define GPU_BPM_FILTER_PEQ_SUBENTRIES        (GPU_BPM_FILTER_PEQ_ENTRY_LENGTH / UINT32_LENGTH)\
##endif@' include/gpu/gpu_config.h

./configure 
make all
mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin
