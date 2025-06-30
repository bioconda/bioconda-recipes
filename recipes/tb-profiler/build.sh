#!/bin/bash

python -m pip install --no-deps --ignore-installed .
cd db
tb-profiler load_lib tbdb
bwa index $PREFIX/share/tbprofiler/tbdb.fasta
