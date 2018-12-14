#!/bin/bash

#git submodule init
#git submodule update --recursive

#Retrieve the submodules, putting them in ./ext
cd ext
rmdir */

#Move submodule lemon
mv ../lemon lemon

#Move submodule seqan
mv ../seqan seqan

cd ../build
cmake -DCMAKE_BUILD_TYPE=Debug ..
make -j 4 anise basil

cp bin/anise bin/basil ../scripts/filter_basil.py $PREFIX/bin/