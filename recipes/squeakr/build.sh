#!/bin/bash

mkdir -p $PREFIX/bin

CFLAGS=-stdlib=libc++ make

cp squeakr-count  $PREFIX/bin
cp squeakr-inner-prod $PREFIX/bin
cp squeakr-query $PREFIX/bin
