#! /bin/bash

cd gdc_2/Gdc2/
if [[ "$OSTYPE" == "linux-gnu" ]]; then
        mv makefile.linux Makefile
elif [[ "$OSTYPE" == "darwin"* ]]; then
        mv makefile.mac Makefile
else
        echo "operating system not found or not supported"
fi
#export CPATH=${PREFIX}/include
#export LD_LIBRARY_PATH=${PREFIX}/lib
make
cp gdc2 $PREFIX/bin/
chmod +x $PREFIX/bin/gdc2