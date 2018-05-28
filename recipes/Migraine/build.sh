#!/bin/bash

g++ -O3 -o migraine *.cpp

cp migraine $PREFIX/bin
chmod +x $PREFIX/bin/migraine