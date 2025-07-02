
cp -rf ${BUILD_PREFIX}/share/gnuconfig/config.* .
cp -rf ${BUILD_PREFIX}/share/gnuconfig/config.* lib/R2R/R2R-current/
cp -rf ${BUILD_PREFIX}/share/gnuconfig/config.* lib/hmmer
cp -rf ${BUILD_PREFIX}/share/gnuconfig/config.* lib/hmmer/easel

./configure --disable-avx512 --prefix=$PREFIX

make V=1
make install
