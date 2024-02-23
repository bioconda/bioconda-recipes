#!/bin/bash

# Adding -v to make breaks compilation on Microsoft Azure CI
make prefix="${PREFIX}" -j"${CPU_COUNT}"
make install
