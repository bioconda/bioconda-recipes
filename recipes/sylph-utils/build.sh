#!/bin/bash

mkdir -p ${PREFIX}/bin
cp -rf eukaryote prokaryote virus ${PREFIX}/bin
install -v -m 0755 merge_sylph_taxprof.py sylph_to_taxprof.py ${PREFIX}/bin
