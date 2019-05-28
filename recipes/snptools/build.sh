#!/usr/bin/env bash

sed -i.bak 's/INCLUDE=-Isamtools-0.1.16 -Itabix-0.2.5//; s/-Lsamtools-0.1.16 -Ltabix-0.2.5//' makefile

make all CC=$CXX

install bamodel poprob probin impute hapfuse $PREFIX/bin

