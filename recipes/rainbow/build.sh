#!/bin/bash

mkdir -p $PREFIX/bin
make

cp rainbow $PREFIX/bin

cp select_all_rbcontig.pl $PREFIX/bin
cp select_best_rbcontig.pl $PREFIX/bin
cp select_sec_rbcontig.pl $PREFIX/bin
cp select_best_rbcontig_plus_read1.pl $PREFIX/bin
