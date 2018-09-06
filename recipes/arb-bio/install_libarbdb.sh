#!/bin/bash

mkdir -p $PREFIX/lib/arb/lib
for LIB in ARBDB CORE; do
    mv install/lib/arb/lib/lib$LIB* $PREFIX/lib/arb/lib
done
