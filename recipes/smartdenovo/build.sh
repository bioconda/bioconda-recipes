#!/bin/bash

mkdir -p $PREFIX/bin

make 

binaries="\
pairaln \ 
wtpre \ 
wtcyc \ 
wtmer \ 
wtzmo \ 
wtobt \ 
wtclp \ 
wtext \ 
wtgbo \ 
wtlay \ 
wtcns \
wtmsa \
smartdenovo.pl \
"

for i in $binaries; do cp $i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done


