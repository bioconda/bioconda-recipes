gawk -i inplace '/usr\/bin\//{ gsub(/python/, "env python");}1' script/*.py
gawk -i inplace '/usr\/bin\//{ gsub(/perl/, "env perl");}1' script/*

aclocal
autoconf
automake --add-missing

export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
./configure --prefix=$PREFIX
make


mkdir -p ${PREFIX}/bin

cp bin/* ${PREFIX}/bin
cp script/*py ${PREFIX}/bin
cp script/validate* ${PREFIX}/bin
