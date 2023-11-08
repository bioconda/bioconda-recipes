#!/bin/bash

./configure

make -j${CPU_COUNT}

cp b/aodp $PREFIX/bin
