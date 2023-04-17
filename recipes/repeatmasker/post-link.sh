#!/bin/sh

RM_DIR=${PREFIX}/share/RepeatMasker

# configure
cd ${RM_DIR}
perl ./configure -libdir ${RM_DIR}/Libraries -trf_prgm ${PREFIX}/bin/trf -rmblast_dir ${PREFIX}/bin/ -hmmer_dir ${PREFIX}/bin -abblast_dir ${PREFIX}/bin -crossmatch_dir ${PREFIX}/bin -default_search_engine rmblast
