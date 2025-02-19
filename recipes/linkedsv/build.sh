#!/usr/bin/env bash

set -xe

export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p ${PREFIX}/bin

## cpp ##
cd src

${CXX} ${CXXFLAGS} -std=c++11 -I ./include/ ${LDFLAGS} -o cluster_reads cluster_reads.cpp tk.cpp cgranges.cpp -l z -pthread
${CXX} ${CXXFLAGS} -std=c++11 -I ./include/ ${LDFLAGS} -o extract_barcode_info extract_barcode_info.cpp -l hts -l z -l m -l pthread
${CXX} ${CXXFLAGS} -std=c++11 -I ./include/ ${LDFLAGS} -o output_bam_coreinfo output_bam_coreinfo.cpp -l hts -l z -l m -l pthread
${CXX} ${CXXFLAGS} -std=c++11 -I ./include/ ${LDFLAGS} -o remove_sparse_nodes remove_sparse_nodes.cpp tk.cpp cgranges.cpp -lz
${CXX} ${CXXFLAGS} -std=c++11 -I ./include/ ${LDFLAGS} -o cal_hap_read_depth_from_bcd21 cal_hap_read_depth_from_bcd21.cpp tk.cpp cgranges.cpp -l z
${CXX} ${CXXFLAGS} -std=c++11 -I ./include/ ${LDFLAGS} -o grid_overlap grid_overlap.cpp tk.cpp cgranges.cpp -l z
${CXX} ${CXXFLAGS} -std=c++11 -I ./include/ ${LDFLAGS} -o cal_read_depth_from_bcd21 cal_read_depth_from_bcd21.cpp tk.cpp cgranges.cpp -l z
${CXX} ${CXXFLAGS} -std=c++11 -I ./include/ ${LDFLAGS} -o cal_barcode_depth_from_bcd21 cal_barcode_depth_from_bcd21.cpp tk.cpp cgranges.cpp -l z
${CXX} ${CXXFLAGS} -std=c++11 -I ./include/ ${LDFLAGS} -o cal_twin_win_bcd_cnt cal_twin_win_bcd_cnt.cpp tk.cpp cgranges.cpp -l z
${CXX} ${CXXFLAGS} -std=c++11 -I ./include/ ${LDFLAGS} -o cal_centroid_from_read_depth cal_centroid_from_read_depth.cpp tk.cpp cgranges.cpp -l z
${CXX} ${CXXFLAGS} -std=c++11 -I ./include/ ${LDFLAGS} -o cal_2d_overlapping_barcodes cal_2d_overlapping_barcodes.cpp tk.cpp cgranges.cpp -l z
${CXX} ${CXXFLAGS} -std=c++11 -I ./include/ ${LDFLAGS} -o small_deletion_detection small_deletion_detection.cpp cnv.cpp tk.cpp cgranges.cpp -l z
${CXX} ${CXXFLAGS} -std=c++11 -I ./include/ ${LDFLAGS} -o cnv_detection cnv_detection.cpp cnv.cpp tk.cpp cgranges.cpp -l z 

install -m 0755 cluster_reads extract_barcode_info output_bam_coreinfo remove_sparse_nodes ${PREFIX}/bin
install -m 0755 cal_hap_read_depth_from_bcd21 grid_overlap cal_read_depth_from_bcd21 cal_barcode_depth_from_bcd21 ${PREFIX}/bin
install -m 0755 cal_twin_win_bcd_cnt cal_centroid_from_read_depth cal_2d_overlapping_barcodes cnv_detection small_deletion_detection ${PREFIX}/bin

cd ..
cp -r scripts ${PREFIX}/bin
cp linkedsv.py ${PREFIX}/bin