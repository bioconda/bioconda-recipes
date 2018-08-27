grep -l -r "/usr/bin/perl" . | xargs sed -i.bak -e 's/usr\/bin\/perl/usr\/bin\/env perl/g'
export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
make install

mkdir -p $PREFIX

if [ `uname` == Darwin ]; then
    cp Darwin-amd64/bin/* $PREFIX/bin/
    cp Darwin-amd64/include/* $PREFIX/include/
    cp Darwin-amd64/lib/* $PREFIX/lib/
else
    cp Linux-amd64/bin/* $PREFIX/bin/
    cp Linux-amd64/include/* $PREFIX/include/
    cp Linux-amd64/lib/* $PREFIX/lib/
fi
