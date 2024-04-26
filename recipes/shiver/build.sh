#!/bin/bash
mkdir $PREFIX/bin
mkdir $PREFIX/bin/tools
mkdir $PREFIX/data
mkdir $PREFIX/data/external
install ${SRC_DIR}/bin/shiver_align_contigs.sh -t $PREFIX/bin
install ${SRC_DIR}/bin/shiver_funcs.sh -t $PREFIX/bin
install ${SRC_DIR}/bin/shiver_init.sh -t $PREFIX/bin
install ${SRC_DIR}/bin/shiver_map_reads.sh -t $PREFIX/bin
install ${SRC_DIR}/bin/config.sh -t $PREFIX/bin

install ${SRC_DIR}/bin/tools/*.py -t $PREFIX/bin/tools/
install ${SRC_DIR}/bin/tools/*.R -t $PREFIX/bin/tools/
install ${SRC_DIR}/bin/tools/*.sh -t $PREFIX/bin/tools/

install ${SRC_DIR}/data/external/B.FR.83.HXB2_LAI_IIIB_BRU.K03455.fasta -t $PREFIX/data/external
