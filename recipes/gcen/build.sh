#!/usr/bash
set -x

g++ src/data_norm.cpp -o data_norm -std=c++17 -static-libstdc++ -O3 -Wall
g++ src/data_filter.cpp -o data_filter -std=c++17 -static-libstdc++ -O3 -Wall
g++ src/network_build.cpp -o network_build -pthread -std=c++17 -static-libstdc++ -O3 -Wall
g++ src/module_identify.cpp -o module_identify -pthread -std=c++17 -static-libstdc++ -O3 -Wall
g++ src/annotate.cpp -o annotate -pthread -lstdc++fs -std=c++17 -static-libstdc++ -O3 -Wall
g++ src/rwr.cpp -o rwr -std=c++17 -static-libstdc++ -O3 -Wall

g++ src/data_stat.cpp -o data_stat -std=c++17 -static-libstdc++ -O3 -Wall
g++ src/network_merge.cpp -o network_merge -std=c++17 -static-libstdc++ -O3 -Wall
g++ src/enrich.cpp -o enrich -std=c++17 -static-libstdc++ -O3 -Wall
g++ src/generate_expr_matrix_from_rsem.cpp -o generate_expr_matrix_from_rsem -std=c++17 -static-libstdc++ -O3 -Wall
g++ src/generate_expr_matrix_from_stringtie.cpp -o generate_expr_matrix_from_stringtie -std=c++17 -static-libstdc++ -O3 -Wall
