#!/bin/bash
make all

binaries="\
graph2asqg \
lsg \
redbuild
"
            
for i in $binaries; do cp bin/$i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done
