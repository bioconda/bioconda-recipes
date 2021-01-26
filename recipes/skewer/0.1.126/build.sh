#!/bin/bash

CXXFLAGS="-c $CXXFLAGS" make CXX="${CXX}"
mkdir -p "${PREFIX}/bin"
cp skewer "${PREFIX}/bin/"
