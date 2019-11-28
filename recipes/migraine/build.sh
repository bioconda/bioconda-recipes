#!/bin/bash

mkdir -p ${PREFIX}/bin
${CXX} -O3 -o ${PREFIX}/bin/migraine *.cpp
