#!/bin/bash

mkdir -p ${PREFIX}/bin/

cp svjedi-graph.py  ${PREFIX}/bin/
cp construct-graph.py ${PREFIX}/bin/
cp filter-alignments.py ${PREFIX}/bin/
cp predict-genotype.py ${PREFIX}/bin/
chmod +x ${PREFIX}/bin/svjedi-graph.py


