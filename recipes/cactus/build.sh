#!/bin/bash

# setup environment variables
export kyotoTycoonIncl="-I${PREFIX}/include -DHAVE_KYOTO_TYCOON=1 -I-I${PREFIX}/lib"
export kyotoTycoonLib="-L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib -lkyototycoon -lkyotocabinet -lz -lpthread -lm -lstdc++ -llzo2"
export CFLAGS="$CFLAGS -fcommon"
export CXXFLAGS="$CXXFLAGS -fcommon"

# some makefiles don't use variables and call gcc or c++/g++. The conda executables have different names
GCC_PATH=$(dirname "${CC}")
cp ${CC} ${GCC_PATH}/gcc
cp ${CXX} ${GCC_PATH}/c++

# empty directories needed for compiles but they are not tracked in the github repository so must be remade
mkdir submodules/sonLib/externalTools/quicktree_1.1/bin
mkdir submodules/hal/lib
mkdir submodules/hal/bin

rm -rf submodules/hdf5
make cxx="${CC} ${CPPFLAGS} ${CFLAGS} ${LDFLAGS}" cpp="${CXX} ${CPPFLAGS} ${CXXFLAGS} ${LDFLAGS}" LDLIBS='-lhdf5_cpp -lhdf5' h5c++="${PREFIX}/bin/h5c++"
$PYTHON -m pip install . --ignore-installed --no-deps -vv

find bin -type f -executable -exec strip {} \;
cp -r bin/* ${PREFIX}/bin

find submodules/hal -name \*.a -o -name \*.o -delete
find submodules/hal -type f -executable -exec strip {} \;
cp -r submodules/hal ${PREFIX}/lib/python2.7/site-packages
for binary in ${PREFIX}/lib/python2.7/site-packages/hal/bin/* ; do
    ln -s ${binary} ${PREFIX}/bin/
done

rm ${GCC_PATH}/gcc
rm ${GCC_PATH}/c++
