#!/bin/bash

# Build conifer
${CC} -std=c99 -Wall -Wextra -O3 -D_POSIX_C_SOURCE=200809L \
    -I $PREFIX/include \
    -I third_party/uthash/src \
    -I . src/utils.c src/kraken_stats.c src/kraken_taxo.c src/main.c \
    -o conifer -lz -lm

# Build is_a_parent_of_b
${CC} -std=c99 -Wall -O3 -D_POSIX_C_SOURCE=200809L \
    -I $PREFIX/include \
    -I third_party/uthash/src \
    -I . src/kraken_stats.c src/kraken_taxo.c utils/is_a_parent_of_b.c \
    -o is_a_parent_of_b -lm
    
# Build show_ancestors
${CC} -std=c99 -Wall -O3 -D_POSIX_C_SOURCE=200809L \
    -I $PREFIX/include \
    -I third_party/uthash/src \
    -I . src/kraken_stats.c src/kraken_taxo.c utils/show_ancestors.c \
    -o show_ancestors -lm

# Build taxid_name
${CC} -std=c99 -Wall -O3 -D_POSIX_C_SOURCE=200809L \
    -I $PREFIX/include \
    -I third_party/uthash/src \
    -I . src/kraken_stats.c src/kraken_taxo.c utils/taxid_name.c \
    -o taxid_name -lm

# Move files
mkdir -p $PREFIX/bin
mv conifer is_a_parent_of_b show_ancestors taxid_name $PREFIX/bin
