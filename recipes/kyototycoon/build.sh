#!/bin/bash


# using default conda libraries for gcc causes the following error:
#    stdlib.h:513:15: error: expected '=', ',', ';', 'asm' or '__attribute__' before 'void'
#      static inline void* aligned_alloc (size_t al, size_t sz)
#
# This is fixed by downloading glibc from asmeurer channel and adding headers to ${PREFIX}/inlude

mkdir glibc
cd glibc
wget https://anaconda.org/asmeurer/glibc/2.19/download/linux-64/glibc-2.19-0.tar.bz2
tar xfvj glibc-2.19-0.tar.bz2
rm -r include/bits/string3.h
cp -r include/* ${PREFIX}/include/
cd ..


# Building Kyotocabinet and Kyototycoon
export CPATH=${PREFIX}/include/:$CPATH
export CXXFLAGS="-no-pie"
make PREFIX=${PREFIX} INCLUDEDIR="${PREFIX}/include/" CMDLIBS="-l kyotocabinet -L${PREFIX}/lib -I${PREFIX}/lib -llzo2 -llua -ldl -lz -I${PREFIX}/include/"
make install


# adding activation and deactivation scripts to set LD_LIBRARY_PATH
mkdir -p ${PREFIX}/etc/conda/activate.d
mkdir -p ${PREFIX}/etc/conda/deactivate.d

if [ ! -f ${PREFIX}/etc/conda/activate.d/env_vars.sh ]; then
    echo "#!/bin/bash" > ${PREFIX}/etc/conda/activate.d/env_vars.sh
fi
echo "export LD_LIBRARY_PATH=${PREFIX}/lib:$LD_LIBRARY_PATH" >> ${PREFIX}/etc/conda/activate.d/env_vars.sh

if [ ! -f ${PREFIX}/etc/conda/deactivate.d/env_vars.sh ]; then
    echo "#!/bin/bash" > ${PREFIX}/etc/conda/deactivate.d/env_vars.sh
fi
echo "unset LD_LIBRARY_PATH" >> ${PREFIX}/etc/conda/deactivate.d/env_vars.sh





