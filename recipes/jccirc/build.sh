#!/bin/bash -euo

mkdir -p $PREFIX/bin

cp JCcirc.pl CircSimu.pl $PREFIX/bin

ln -s $PREFIX/bin/JCcirc.pl $PREFIX/bin/JCcirc
chmod a+x $PREFIX/bin/JCcirc.pl

ln -s $PREFIX/bin/CircSimu.pl $PREFIX/bin/CircSimu
chmod a+x $PREFIX/bin/CircSimu.pl
