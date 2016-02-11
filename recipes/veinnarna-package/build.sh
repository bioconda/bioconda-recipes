# use anaconda's build environment

CC=${PREFIX}/bin/gcc
CXX=${PREFIX}/bin/g++

./configure --prefix=$PREFIX

make check install
