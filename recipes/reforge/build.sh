#!/bin/bash
export LIBRARY_PATH="$PREFIX/lib"
export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/out

mv stubb.patch $PREFIX/out

ln  "$CC" "$PREFIX/bin/gcc"
ln  "$CXX" "$PREFIX/bin/g++"

wget https://github.com/UIUCSinhaLab/Stubb/raw/main/stubb_2.1.tar.gz
tar -xvf stubb_2.1.tar.gz
wget http://www.robertnz.net/ftp/newmat11.tar.gz
tar -xvf newmat11.tar.gz -C stubb_2.1/lib/newmat/

patch -p1 < $PREFIX/out/stubb.patch
cd lib/newmat/
gmake -f nm_gnu.mak
cd ../../
make

mv *.py $PREFIX/bin/
mv stubb_2.1/bin/* $PREFIX/bin/
