#!/bin/bash
make CC=$CC CXX="${CXX}"
mkdir -p $PREFIX/bin
cp viral_consensus $PREFIX/bin/
