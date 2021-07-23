#!/bin/bash
OUTDIR=$PREFIX/share/phylowgs
mkdir -p $OUTDIR
"${CXX}" ${CPPFLAGS} ${CXXFLAGS} ${LDFLAGS} \
    -o mh.o  mh.cpp  util.cpp `gsl-config --cflags --libs`
cp -r * $OUTDIR/
chmod a+x $OUTDIR/evolve.py
chmod a+x $OUTDIR/parser/create_phylowgs_inputs.py
chmod a+x $OUTDIR/multievolve.py
chmod a+x $OUTDIR/write_results.py
mkdir -p ${PREFIX}/bin
ln -s \
    $OUTDIR/evolve.py \
    $OUTDIR/parser/create_phylowgs_inputs.py \
    $OUTDIR/write_results.py \
    $PREFIX/bin/
echo "#!/usr/bin/env python2" > $PREFIX/bin/multievolve.py
cat $OUTDIR/multievolve.py >> $PREFIX/bin/multievolve.py
chmod +x $PREFIX/bin/multievolve.py
#ln -s $OUTDIR/multievolve.py $PREFIX/bin/
