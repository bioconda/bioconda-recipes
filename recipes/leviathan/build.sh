#!/bin/bash

make -j"${CPU_COUNT}" BUILD_DIR=$PREFIX
make install BUILD_DIR=$PREFIX
