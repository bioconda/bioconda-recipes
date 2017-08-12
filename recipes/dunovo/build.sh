#!/bin/bash

make
mv *.so $PREFIX/lib
mv ET $PREFIX/lib/ET
mv utillib $PREFIX/lib/utillib
for script in *.awk *.sh *.py; do
  mv $script $PREFIX/lib
  ln -s ../lib/$script $PREFIX/bin
done
mv utils/outconv.py $PREFIX/lib
ln -s ../lib/outconv.py $PREFIX/bin
