#!/bin/bash

sed -i.bak 's/-DUSE_MPI//g' Makefile

make CC="${CXX_FOR_BUILD}" all

cp tntblast $PREFIX/bin
