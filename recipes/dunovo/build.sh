#!/bin/bash

# Compile binaries and move them to lib.
make
mv *.so $PREFIX/lib

# Download submodules and move them to lib.
wget 'https://github.com/NickSto/utillib/archive/v0.1.0.tar.gz'
tar -zxvpf v0.1.0.tar.gz
mv utillib-0.1.0 $PREFIX/lib/utillib
rm v0.1.0.tar.gz
wget 'https://github.com/NickSto/ET/archive/v0.1.0.tar.gz'
tar -zxvpf v0.1.0.tar.gz
mv ET-0.1.0 $PREFIX/lib/ET
rm v0.1.0.tar.gz

# Move scripts to lib and link to them from bin.
for script in *.awk *.sh *.py; do
  mv $script $PREFIX/lib
  ln -s ../lib/$script $PREFIX/bin
done
mv utils/outconv.py $PREFIX/lib
ln -s ../lib/outconv.py $PREFIX/bin
