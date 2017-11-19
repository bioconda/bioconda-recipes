#!/bin/bash

# Download submodules and move them to lib.
## kalign
kalignver=0.2.0
wget --no-check-certificate "https://github.com/makrutenko/kalign-dunovo/archive/v$kalignver.tar.gz"
hash=`sha256sum v$kalignver.tar.gz | tr -s ' ' | cut -d ' ' -f 1`
[ $hash = 473dd562f520a218df2dd147c89940422344adad6d8824141bffe6466c6d40e7 ]
tar -zxvpf v$kalignver.tar.gz
rm -rf kalign
mv kalign-dunovo-$kalignver kalign
rm v$kalignver.tar.gz
## utillib
utilver=0.1.0
wget --no-check-certificate "https://github.com/NickSto/utillib/archive/v$utilver.tar.gz"
hash=`sha256sum v$utilver.tar.gz | tr -s ' ' | cut -d ' ' -f 1`
[ $hash = bffe515f7bd98661657c26003c41c1224f405c3a36ddabf5bf961fab86f9651a ]
tar -zxvpf v$utilver.tar.gz
mv utillib-$utilver $PREFIX/lib/utillib
rm v$utilver.tar.gz
## ET
ETver=0.2.2
wget --no-check-certificate "https://github.com/NickSto/ET/archive/v$ETver.tar.gz"
hash=`sha256sum v$ETver.tar.gz | tr -s ' ' | cut -d ' ' -f 1`
[ $hash = 11dc5cb02521a2260e6c88a83d489c72f819bd759aeff31d66aa40ca2f1358a6 ]
tar -zxvpf v$ETver.tar.gz
mv ET-$ETver $PREFIX/lib/ET
rm v$ETver.tar.gz

# Compile binaries and move them to lib.
make
mv *.so $PREFIX/lib
mv kalign $PREFIX/lib

# Move scripts to lib and link to them from bin.
for script in *.awk *.sh *.py; do
  mv $script $PREFIX/lib
  ln -s ../lib/$script $PREFIX/bin
done
# Handle special cases.
mv utils/outconv.py $PREFIX/lib
ln -s ../lib/outconv.py $PREFIX/bin
mv VERSION $PREFIX/lib
