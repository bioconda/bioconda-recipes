#!/bin/bash
mkdir $PREFIX/bin
mkdir $PREFIX/bin/tools 
install ${SRC_DIR}/shiver_align_contigs.sh -t $PREFIX/bin
install ${SRC_DIR}/shiver_full_auto.sh -t $PREFIX/bin
install ${SRC_DIR}/shiver_funcs.sh -t $PREFIX/bin
install ${SRC_DIR}/shiver_init.sh -t $PREFIX/bin
install ${SRC_DIR}/shiver_map_reads.sh -t $PREFIX/bin

install ${SRC_DIR}/tools/*.py -t $PREFIX/bin/tools/
install ${SRC_DIR}/tools/*.R -t $PREFIX/bin/tools/
install ${SRC_DIR}/tools/*.sh -t $PREFIX/bin/tools/




