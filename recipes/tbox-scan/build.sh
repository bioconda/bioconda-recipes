#!bin/bash

#Make the /bin directory. $PREFIX is defined by conda
mkdir -p $PREFIX/bin
#We don't actually need to compile anything, just copy the scripts
cp tbox-scan $PREFIX/bin
cp -r tboxscan $PREFIX/bin