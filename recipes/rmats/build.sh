#!/bin/bash

mkdir $PREFIX/rMATS

GSL_LDFLAGS="$(gsl-config --libs)"
GSL_CFLAGS="$(gsl-config --cflags)"
export GSL_LDFLAGS
export GSL_CFLAGS

export CXXFLAGS="${CXXFLAGS} -std=c++03"

make

cp rmats.py $PREFIX/rMATS
mkdir $PREFIX/rMATS/rMATS_C
cp rMATS_C/rMATSexe $PREFIX/rMATS/rMATS_C
cp -R rMATS_P $PREFIX/rMATS
cp -R rMATS_R $PREFIX/rMATS
cp *.so $PREFIX/rMATS

chmod +x $PREFIX/rMATS/rmats.py
ln -s $PREFIX/rMATS/rmats.py $PREFIX/bin/rmats.py
ln -s $PREFIX/rMATS/rMATS_P/FDR.py $PREFIX/bin/FDR.py
ln -s $PREFIX/rMATS/rMATS_P/inclusion_level.py $PREFIX/bin/inclusion_level.py
ln -s $PREFIX/rMATS/rMATS_P/joinFiles.py $PREFIX/bin/joinFiles.py
ln -s $PREFIX/rMATS/rMATS_P/paste.py $PREFIX/bin/paste.py

# for backwards compatibility with the previous recipe, create a symlink named
# for the previously-used executable
ln -s $PREFIX/rMATS/rmats.py $PREFIX/bin/RNASeq-MATS.py
