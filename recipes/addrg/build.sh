#!/bin/bash

$CC -o $PREFIX/bin/addrg -Wall -O2 addrg.c -I$PREFIX/include -L$PREFIX/lib -lhts -lz -lpthread
