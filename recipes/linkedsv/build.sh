#!/bin/bash

mkdir -p ${PREFIX}/bin

## cpp ##
cd src

${CXX} -g -O0 -std=c++11 -I ./include/ -L $PREFIX/lib -o cluster_reads cluster_reads.cpp tk.cpp cgranges.cpp -l z -pthread
${CXX} -g -O0 -std=c++11 -I ./include/ -L $PREFIX/lib -o extract_barcode_info extract_barcode_info.cpp -l hts -l z -l m -l pthread
${CXX} -g -O0 -std=c++11 -I ./include/ -L $PREFIX/lib -o output_bam_coreinfo output_bam_coreinfo.cpp -l hts -l z -l m -l pthread
${CXX} -g -O0 -std=c++11 -I ./include/ -L $PREFIX/lib -o remove_sparse_nodes remove_sparse_nodes.cpp tk.cpp cgranges.cpp -lz
${CXX} -g -O0 -std=c++11 -I ./include/ -L $PREFIX/lib -o cal_hap_read_depth_from_bcd21 cal_hap_read_depth_from_bcd21.cpp tk.cpp cgranges.cpp -l z
${CXX} -g -O0 -std=c++11 -I ./include/ -L $PREFIX/lib -o grid_overlap grid_overlap.cpp tk.cpp cgranges.cpp -l z
${CXX} -g -O0 -std=c++11 -I ./include/ -L $PREFIX/lib -o cal_read_depth_from_bcd21 cal_read_depth_from_bcd21.cpp tk.cpp cgranges.cpp -l z
${CXX} -g -O0 -std=c++11 -I ./include/ -L $PREFIX/lib -o cal_barcode_depth_from_bcd21 cal_barcode_depth_from_bcd21.cpp tk.cpp cgranges.cpp -l z
${CXX} -g -O0 -std=c++11 -I ./include/ -L $PREFIX/lib -o cal_twin_win_bcd_cnt cal_twin_win_bcd_cnt.cpp tk.cpp cgranges.cpp -l z
${CXX} -g -O0 -std=c++11 -I ./include/ -L $PREFIX/lib -o cal_centroid_from_read_depth cal_centroid_from_read_depth.cpp tk.cpp cgranges.cpp -l z
${CXX} -g -O0 -std=c++11 -I ./include/ -L $PREFIX/lib -o cal_2d_overlapping_barcodes cal_2d_overlapping_barcodes.cpp tk.cpp cgranges.cpp -l z
${CXX} -g -O0 -std=c++11 -I ./include/ -L $PREFIX/lib -o small_deletion_detection small_deletion_detection.cpp cnv.cpp tk.cpp cgranges.cpp -l z
${CXX} -g -O0 -std=c++11 -I ./include/ -L $PREFIX/lib -o cnv_detection cnv_detection.cpp cnv.cpp tk.cpp cgranges.cpp -l z 

mv cluster_reads extract_barcode_info output_bam_coreinfo remove_sparse_nodes ${PREFIX}/bin
mv cal_hap_read_depth_from_bcd21 grid_overlap cal_read_depth_from_bcd21 cal_barcode_depth_from_bcd21 ${PREFIX}/bin
mv cal_twin_win_bcd_cnt cal_centroid_from_read_depth cal_2d_overlapping_barcodes cnv_detection small_deletion_detection ${PREFIX}/bin
