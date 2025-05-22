#!/usr/bin/env bash

mkdir -p $PREFIX/bin

files=(polap
	polap-ncbitools
	polap-batch-v0.sh
	polap-batch-v2.sh
	polap-data-v0.sh
	polap-data-v1.sh
	polap-data-v2.sh
	polap-data-v3.sh
	polap-data-v4.sh
	polap.sh)

for i in "${files[@]}"; do
	cp src/$i $PREFIX/bin
done
cp -pr src/polaplib $PREFIX/bin

chmod +x $PREFIX/bin/polap
chmod +x $PREFIX/bin/polap.sh
