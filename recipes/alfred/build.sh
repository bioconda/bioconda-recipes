#!/bin/sh

CXXFLAGS="${CXXFLAGS} -D__STDC_FORMAT_MACROS" make CXX="${CXX}" prefix="${PREFIX}" install
