#!/bin/bash

${CXX} -O3 -o migraine *.cpp

cp migraine $PREFIX/bin
