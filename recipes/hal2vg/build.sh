#!/bin/bash

make cpp="${CXX}" -j"${CPU_COUNT}"
ls -l  # presumably the binaries are here
