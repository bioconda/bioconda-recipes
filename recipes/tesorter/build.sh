#!/bin/bash
$PYTHON -m pip install --no-deps --ignore-installed .

# hmmscan in TEsorter need hmmpress first
# see here https://github.com/oushujun/EDTA/issues/121
echo "Run hmmpress to get the DB ready to use"
cd $SP_DIR/TEsorter/database
for i in `ls *hmm | sed 's/.hmm//g'`; do hmmpress ${i}.hmm > ../${i}.hmm;done
