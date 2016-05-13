#!/bin/sh
cd segemehl
make -j 1 ## do not use >1 make threads!

install -t $PREFIX/bin *.x
