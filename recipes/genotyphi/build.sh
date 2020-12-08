#!/bin/bash
set +ex
mkdir -p $PREFIX/bin
cp genotyphi.py $PREFIX/bin/genotyphi.py
ln $PREFIX/bin/genotyphi.py $PREFIX/bin/genotyphi
chmod +x $PREFIX/bin/genotyphi.py $PREFIX/bin/genotyphi
$PREFIX/bin/genotyphi -h
