#!/bin/bash

make clean
make -j${CPU_COUNT}
make install PREFIX=$PREFIX