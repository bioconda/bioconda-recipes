#!/usr/bash
set -x

$CXX src/data_norm.cpp -o $PREFIX/data_norm -std=c++17 -static-libstdc++ -O3 -Wall
$CXX src/data_filter.cpp -o $PREFIX/data_filter -std=c++17 -static-libstdc++ -O3 -Wall
$CXX src/network_build.cpp -o $PREFIX/network_build -pthread -std=c++17 -static-libstdc++ -O3 -Wall
$CXX src/module_identify.cpp -o $PREFIX/module_identify -pthread -std=c++17 -static-libstdc++ -O3 -Wall
$CXX src/annotate.cpp -o $PREFIX/annotate -pthread -lstdc++fs -std=c++17 -static-libstdc++ -O3 -Wall
$CXX src/rwr.cpp -o $PREFIX/rwr -std=c++17 -static-libstdc++ -O3 -Wall

$CXX src/data_stat.cpp -o $PREFIX/data_stat -std=c++17 -static-libstdc++ -O3 -Wall
$CXX src/network_merge.cpp -o $PREFIX/network_merge -std=c++17 -static-libstdc++ -O3 -Wall
$CXX src/enrich.cpp -o $PREFIX/enrich -std=c++17 -static-libstdc++ -O3 -Wall
$CXX src/generate_expr_matrix_from_rsem.cpp -o $PREFIX/generate_expr_matrix_from_rsem -std=c++17 -static-libstdc++ -O3 -Wall
$CXX src/generate_expr_matrix_from_stringtie.cpp -o $PREFIX/generate_expr_matrix_from_stringtie -std=c++17 -static-libstdc++ -O3 -Wall
