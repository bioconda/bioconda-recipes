#!/bin/sh
set -e


mkdir -p $PREFIX/bin

cp kaptive.py $PREFIX/bin
cp extras/kaptive_slurm.py $PREFIX/bin

chmod a+x $PREFIX/bin/kaptive.py
chmod a+x $PREFIX/bin/kaptive_slurm.py
