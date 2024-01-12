#!/bin/bash

sed -i.bak 's/-DUSE_MPI//g' Makefile
sed -i.bak '/BLAST_DIR =/d' Makefile

make CC="${CXX_FOR_BUILD}" all

cp tntblast $PREFIX/bin
