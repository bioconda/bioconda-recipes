#!/bin/bash

mkdir -p ${PREFIX}/bin
make CXX="${CXX}"
make install
