#!/bin/bash
OUTDIR=$PREFIX/share/phylowgs
mkdir -p $OUTDIR
g++ -o mh.o  mh.cpp  util.cpp `gsl-config --cflags --libs`
cp -r * $OUTDIR
chmod a+x $OUTDIR/evolve.py
chmod a+x $OUTDIR/parser/create_phylowgs_inputs.py
ln -s $OUTDIR/evolve.py $PREFIX/bin/evolve.py
ln -s $OUTDIR/parser/create_phylowgs_inputs.py $PREFIX/bin/create_phylowgs_inputs.py
