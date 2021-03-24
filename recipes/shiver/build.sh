#!/bin/bash
mkdir -p $PREFIX/bin
cp ${SRC_DIR}/config.sh $PREFIX/bin/shiver_config.sh
cp ${SRC_DIR}/shiver_align_contigs.sh $PREFIX/bin
cp ${SRC_DIR}/shiver_full_auto.sh $PREFIX/bin
cp ${SRC_DIR}/shiver_funcs.sh $PREFIX/bin
cp ${SRC_DIR}/shiver_init.sh $PREFIX/bin
cp ${SRC_DIR}/shiver_map_reads.sh $PREFIX/bin


cp -r ${SRC_DIR}/tools $PREFIX/bin/tools
