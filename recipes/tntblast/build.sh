#!/bin/bash

sed -i.bak 's/-DUSE_MPI//g' Makefile
sed -i.bak '/BLAST_DIR =/d' Makefile
sed -i.bak 's/$(CC) $(FLAGS) $(INC)/$(CC) $(FLAGS) $(INC) $(LIBS)/g' Makefile

make CC="${CXX_FOR_BUILD}" all

cp tntblast $PREFIX/bin
