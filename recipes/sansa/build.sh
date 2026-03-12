#!/bin/bash

CXXFLAGS="${CXXFLAGS} -O3 -D__STDC_FORMAT_MACROS" make -j${CPU_COUNT} CXX="${CXX}" prefix="${PREFIX}" install
