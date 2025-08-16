#!/bin/bash

python -m pip install --no-deps --ignore-installed .
cd db
python ../tb-profiler load_library tbdb
bwa index $PREFIX/share/tbprofiler/tbdb.fasta
