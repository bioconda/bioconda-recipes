#!/bin/bash

mkdir $PREFIX/rMATS

if [[ "$(uname)" == "Darwin" ]]; then
    SRCDIR="rMATS-turbo-Mac-UCS4"
else
    SRCDIR="rMATS-turbo-Linux-UCS4"
fi

cp -R $SRCDIR/* $PREFIX/rMATS
chmod +x $PREFIX/rMATS/rmats.py
ln -s $PREFIX/rMATS/rmats.py $PREFIX/bin/rmats.py
ln -s $PREFIX/rMATS/rMATS_P/FDR.py $PREFIX/bin/FDR.py
ln -s $PREFIX/rMATS/rMATS_P/inclusion_level.py $PREFIX/bin/inclusion_level.py
ln -s $PREFIX/rMATS/rMATS_P/joinFiles.py $PREFIX/bin/joinFiles.py
ln -s $PREFIX/rMATS/rMATS_P/paste.py $PREFIX/bin/paste.py

# for backwards compatibility with the previous recipe, create a symlink named
# for the previously-used executable
ln -s $PREFIX/rMATS/rmats.py $PREFIX/bin/RNASeq-MATS.py
