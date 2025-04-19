#!/bin/bash

export RBT_ROOT=${PREFIX}/rDock

make -j${CPU_COUNT}
PREFIX=${PREFIX} make install
