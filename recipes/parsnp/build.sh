#!/bin/bash


mkdir -p  "$PREFIX/bin"



./autogen.sh
#>&2 ls ${CONDA_PREFIX}/include/libMUSCLE-3.7/*/*
#>&2 echo $LD_LIBRARY_PATH
#export LD_LIBRARY_PATH=${CONDA_PREFIX}/lib:$LD_LIBRARY_PATH
./configure -with-libmuscle=${CONDA_PREFIX}/include/libMUSCLE-3.7 || true
>&2 cat config.log
make LDADD='-lMUSCLE-3.7' 
make install


cp parsnp $PREFIX/bin 
cp Parsnp.py $PREFIX/bin
cp template.ini $PREFIX/bin
cp -R bin $PREFIX/bin 
cp -R muscle $PREFIX/bin 
cp -R examples $PREFIX/bin

