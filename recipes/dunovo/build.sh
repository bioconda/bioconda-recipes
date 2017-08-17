#!/bin/bash
set -x
# Compile binaries and move them to lib.
make
mv *.so $PREFIX/lib

# Download submodules and move them to lib.
wget --no-check-certificate 'https://github.com/NickSto/utillib/archive/v0.1.0.tar.gz'
hash=`sha256sum v0.1.0.tar.gz | tr -s ' ' | cut -d ' ' -f 1`
[ $hash == bffe515f7bd98661657c26003c41c1224f405c3a36ddabf5bf961fab86f9651a ]
tar -zxvpf v0.1.0.tar.gz
mv utillib-0.1.0 $PREFIX/lib/utillib
rm v0.1.0.tar.gz
wget --no-check-certificate 'https://github.com/NickSto/ET/archive/v0.1.0.tar.gz'
hash=`sha256sum v0.1.0.tar.gz | tr -s ' ' | cut -d ' ' -f 1`
[ $hash == 57c2050715bd7383dc35ed4e1ad7f9078749a6b2459fd1730b8928fd0cbb2c5c ]
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
