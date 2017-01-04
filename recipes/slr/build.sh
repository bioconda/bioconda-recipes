#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

cd src/

if [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "Platform: Linux"
    # modifies makefile to use openblas
    perl -p -i -e 's/-lblas -llapack/-lopenblas/g' Makefile.linux
    make -f Makefile.linux
    cp Slr $PREFIX/bin
fi
