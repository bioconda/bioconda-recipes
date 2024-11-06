#!/usr/bin/env bash

mkdir -p $PREFIX/bin

files=(polap
	polap-conda-environment-fmlrc.yaml
	polap-conda-environment.yaml
	polap-mt.1.c70.3.faa
	polap-parsing.sh
	polap-pt.2.c70.3.faa
	polap.sh
	run-polap-r-genes.R
	run-polap-r-jellyfish.R
	run-polap-r-mtcontig.R
	run-polap-ncbitools
	run-polap-r-pairs.R)

for i in "${files[@]}"; do
	cp src/$i $PREFIX/bin
done

chmod +x $PREFIX/bin/polap
chmod +x $PREFIX/bin/polap.sh
chmod +x $PREFIX/bin/run-polap-*
