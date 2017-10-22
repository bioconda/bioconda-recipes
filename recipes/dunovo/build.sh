#!/bin/bash

# Compile binaries and move them to lib.
make
mv *.so $PREFIX/lib

# Download submodules and move them to lib.
## utillib
utilver=0.1.0
wget --no-check-certificate "https://github.com/NickSto/utillib/archive/v$utilver.tar.gz"
hash=`sha256sum v$utilver.tar.gz | tr -s ' ' | cut -d ' ' -f 1`
[ $hash = bffe515f7bd98661657c26003c41c1224f405c3a36ddabf5bf961fab86f9651a ]
tar -zxvpf v$utilver.tar.gz
mv utillib-$utilver $PREFIX/lib/utillib
rm v$utilver.tar.gz
## ET
ETver=0.1.1
wget --no-check-certificate "https://github.com/NickSto/ET/archive/v$ETver.tar.gz"
hash=`sha256sum v$ETver.tar.gz | tr -s ' ' | cut -d ' ' -f 1`
[ $hash = 552c371f0fe0000b6037038ad1aeae09111d066c362d45655e40381cb0c325e4 ]
tar -zxvpf v$ETver.tar.gz
mv ET-$ETver $PREFIX/lib/ET
rm v$ETver.tar.gz

# Move scripts to lib and link to them from bin.
for script in *.awk *.sh *.py; do
  mv $script $PREFIX/lib
  ln -s ../lib/$script $PREFIX/bin
done
# Handle special cases.
mv utils/outconv.py $PREFIX/lib
ln -s ../lib/outconv.py $PREFIX/bin
mv VERSION $PREFIX/lib
