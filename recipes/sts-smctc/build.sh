#!/bin/bash

make libraries
cp lib/libsmctc.a ${PREFIX}/lib
cp include/*.hh ${PREFIX}/include
