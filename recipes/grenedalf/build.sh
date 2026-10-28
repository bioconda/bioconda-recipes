#!/bin/bash

make -j ${CPU_COUNT}

mkdir -p $PREFIX/bin

cp bin/grenedalf $PREFIX/bin

