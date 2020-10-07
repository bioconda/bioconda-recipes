#!/bin/bash

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${PREFIX}/lib
export CFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"

cp vars/*.h .
cp vars/*.pxd .
cp vars/*.pyx .
cp vars/*.c .

python setup.py build_ext
python setup.py install

# copy scripts
chmod +x chooseK.py
chmod +x distruct.py
chmod +x structure.py
cp chooseK.py ${PREFIX}/bin
cp distruct.py ${PREFIX}/bin
cp structure.py ${PREFIX}/bin
