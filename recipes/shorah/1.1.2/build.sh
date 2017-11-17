#!/bin/bash

./configure --prefix="${PREFIX}" PYTHON="${PYTHON}"
make
make install
