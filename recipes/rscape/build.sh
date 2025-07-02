
cp -rf ${BUILD_PREFIX}/share/gnuconfig/config.* .

./configure --disable-avx512 --prefix=$PREFIX

make V=1
make install
