#!/bin/bash


# adding activation and deactivation scripts to set PYTHONPATH
mkdir -p ${PREFIX}/etc/conda/activate.d
mkdir -p ${PREFIX}/etc/conda/deactivate.d

if [ ! -f ${PREFIX}/etc/conda/activate.d/env_vars.sh ]; then
    echo "#!/bin/bash" > ${PREFIX}/etc/conda/activate.d/env_vars.sh
fi
echo "PYTHONPATH=${PREFIX}/lib/python2.7/site-packages:${PYTHONPATH}" >> ${PREFIX}/etc/conda/activate.d/env_vars.sh

if [ ! -f ${PREFIX}/etc/conda/deactivate.d/env_vars.sh ]; then
    echo "#!/bin/bash" > ${PREFIX}/etc/conda/deactivate.d/env_vars.sh
fi
echo "unset PYTHONPATH" >> ${PREFIX}/etc/conda/deactivate.d/env_vars.sh



# setup environment variables
export PYTHONPATH=${PREFIX}/lib/python2.7/site-packages:${PYTHONPATH}
export kyotoTycoonIncl="-I${PREFIX}/include -DHAVE_KYOTO_TYCOON=1 -I-I${PREFIX}/lib"
export kyotoTycoonLib="-L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib -lkyototycoon -lkyotocabinet -lz -lpthread -lm -lstdc++ -llzo2"
export LD_LIBRARY_PATH=${PREFIX}/lib
export CPATH=$PREFIX/include

# some makefiles don't use variables and call gcc or c++/g++. The conda executables have different names
GCC_PATH=$(dirname "${CC}")
cp ${CC} ${GCC_PATH}/gcc
cp ${CXX} ${GCC_PATH}/c++

# empty directories needed for compiles but they are not tracked in the github repository so must be remade
mkdir submodules/sonLib/externalTools/quicktree_1.1/bin
mkdir submodules/hal/lib
mkdir submodules/hal/bin

make
$PYTHON setup.py install
cp -r bin/* ${PREFIX}/bin
cp -r submodules/hal ${PREFIX}/lib/python2.7/site-packages






