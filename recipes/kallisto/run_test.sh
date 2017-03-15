#!/bin/bash

# Seems like the only way to trigger HDF5 version mismatches is to actually run
# kallisto.

kallisto index -i t.idx t.fa
kallisto quant t.fq -i t.idx --single -l 300 -s 2 -o tmp
