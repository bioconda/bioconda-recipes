#!/usr/bin/env bash

mkdir -p $PREFIX/bin

files=(polap-ncbitools
	bolap.sh
	polap.sh)

for i in "${files[@]}"; do
	cp src/$i $PREFIX/bin
	chmod +x $PREFIX/bin/$i
done
cp -p src/polap.sh $PREFIX/bin/polap
cp -p src/bolap.sh $PREFIX/bin/bolap
cp -pr src/polaplib $PREFIX/bin

chmod +x $PREFIX/bin/polap
chmod +x $PREFIX/bin/polap.sh
chmod +x $PREFIX/bin/polap-ncbitools
chmod +x $PREFIX/bin/bolap
chmod +x $PREFIX/bin/bolap.sh
