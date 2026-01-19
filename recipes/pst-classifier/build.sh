#!/bin/bash

mkdir -p $PREFIX/bin

mkdir ${SRC_DIR}/build
cd ${SRC_DIR}/build

cmake -DCMAKE_BUILD_TYPE=Release ..
make pst-classifier pst-batch-training pst-score-sequences probabilistic_suffix_tree_map_tests probabilistic_suffix_tree_tests

cp src/pst-classifier src/pst-batch-training src/pst-score-sequences tests/probabilistic_suffix_tree_map_tests tests/probabilistic_suffix_tree_tests $PREFIX/bin
