#!/bin/sh

CXXFLAGS="${CXXFLAGS} -D__STDC_FORMAT_MACROS" make -j${CPU_COUNT} CXX="${CXX}" prefix="${PREFIX}" install
