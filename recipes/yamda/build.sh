#!/bin/bash
PYVER=`python -c 'import sys; print(str(sys.version_info[0])+"."+str(sys.version_info[1]))'`
OUTDIR=$PREFIX/lib/python$PYVER/site-packages

mkdir -p $OUTDIR

cp -r yamda $OUTDIR
cp run_em.py $PREFIX/bin/
cp erase_annoying_sequences.py $PREFIX/bin/
