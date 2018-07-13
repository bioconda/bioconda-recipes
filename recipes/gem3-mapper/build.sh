#!/bin/bash

sed -i.bak 's@#include "resources/gem-cutter/gpu_interface.h"@#ifdef HAVE_CUDA\
#include "resources/gem-cutter/gpu_interface.h"\
#else\
#define GPU_BPM_ALIGN_PEQ_ALPHABET_SIZE     5\
#define GPU_BPM_ALIGN_PEQ_ENTRY_LENGTH      128\
#define GPU_BPM_ALIGN_PEQ_SUBENTRY_LENGTH   32\
#define GPU_BPM_ALIGN_PEQ_SUBENTRIES        (GPU_BPM_ALIGN_PEQ_ENTRY_LENGTH / UINT32_LENGTH)\
\
#define GPU_BPM_FILTER_PEQ_ALPHABET_SIZE     5\
#define GPU_BPM_FILTER_PEQ_ENTRY_LENGTH      128\
#define GPU_BPM_FILTER_PEQ_SUBENTRY_LENGTH   32\
#define GPU_BPM_FILTER_PEQ_SUBENTRIES        (GPU_BPM_FILTER_PEQ_ENTRY_LENGTH / UINT32_LENGTH)\
#endif@' include/gpu/gpu_config.h

./configure --disable-cuda
make
mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin
