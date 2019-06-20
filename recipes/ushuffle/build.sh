python setup.py install
gcc -O3 -g -o ushuffle main.c ushuffle.c
install ushuffle $PREFIX/bin
