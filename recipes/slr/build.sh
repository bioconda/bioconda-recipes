#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

cd src/

if [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "Platform: Linux"
    # modifies makefile to use openblas
    patch Makefile.linux $RECIPE_DIR/openblas.patch
    make -f Makefile.linux
    cp Slr $PREFIX/bin
elif [ "$(uname)" == "Darwin" ]; then
    echo "Platform: OSX"
    # modifies makefile to use openblas
    #patch Makefile.linux $RECIPE_DIR/openblas.patch
    #make -f Makefile.linux
    make -f Makefile.osx
    cp Slr $PREFIX/bin
fi
