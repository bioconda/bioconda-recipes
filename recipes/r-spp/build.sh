#!/bin/bash
export LDFLAGS=-L${PREFIX}/lib
export CPPFLAGS="${CPPFLAGS} -ferror-limit=0"
export CFLAGS="${CFLAGS} -ferror-limit=0"
export CXXFLAGS="${CXXFLAGS} -ferror-limit=0"
export BOOST_ROOT=${PREFIX}
$R CMD INSTALL --build .
