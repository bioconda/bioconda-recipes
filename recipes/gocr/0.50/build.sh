#!/bin/bash

./configure --prefix="${PREFIX}"
make libs -j"${CPU_COUNT}"
make all install
