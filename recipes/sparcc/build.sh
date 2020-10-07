#!/bin/bash

cp *.py $PREFIX/bin
for script in SparCC.py PseudoPvals.py MakeBootstraps.py ; do
  chmod a+x $PREFIX/bin/$script
done
