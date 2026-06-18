#!/bin/bash

./configure --prefix="${PREFIX}" CC="${CC}"
make libs -j"${CPU_COUNT}"
make all install
