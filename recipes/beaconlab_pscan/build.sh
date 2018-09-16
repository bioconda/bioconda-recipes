#!/bin/bash

g++ pscan.cpp -o pscan -O3 -lgsl -lgslcblas -I$(PREFIX)/include -L$(PREFIX)/lib

mv $SRC_DIR/pscan $PREFIX/bin/
chmod +x $PREFIX/bin/pscan