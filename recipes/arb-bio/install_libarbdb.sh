#!/bin/bash

mkdir -p $PREFIX/lib/arb/lib
for fn in libARBDB libCORE arb_tcp.dat; do
    mv install/lib/arb/lib/$LIB* $PREFIX/lib/arb/lib
done
