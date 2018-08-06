./configure --disable-avx512 --prefix=$PREFIX

make clean
make V=1 -j 4
make install
