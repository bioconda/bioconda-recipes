#!/bin/bash
./autogen.sh
./configure --prefix=${PREFIX} --with-libmuscle=${PREFIX}/include/libMUSCLE-3.7/
make 
make install
ls -Srthl src/*
ls -Srthl bin/*

mv src/parsnp ${PREFIX}/bin/ 
