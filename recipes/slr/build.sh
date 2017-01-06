#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include


mkdir -p bin

cd src/

if [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "Platform: Linux"
    export BLASDIR=$PREFIX/lib
    # modifies makefile to use openblas
    patch Makefile.linux $RECIPE_DIR/openblas.patch
    make -f Makefile.linux
    cp ../bin/Slr $PREFIX/bin
elif [ "$(uname)" == "Darwin" ]; then
    echo "Platform: OSX"
    # modifies makefile to use openblas
    patch Makefile.osx $RECIPE_DIR/framework.patch
    make -f Makefile.osx
    otool -L ../bin/Slr
    cp ../bin/Slr $PREFIX/bin
fi
