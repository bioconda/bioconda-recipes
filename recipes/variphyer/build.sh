#!/bin/bash

# define and make a src folder
VARIPHYER=${PREFIX}/share/${PKG_NAME}
mkdir -p ${VARIPHYER}

# copy everything into src folder
cp -r ./* ${VARIPHYER}

chmod 777 ${VARIPHYER}/vaphy

#make a bin folder
mkdir -p ${PREFIX}/bin 

ln -s ${VARIPHYER}/vaphy ${PREFIX}/bin/vaphy
ln -s ${VARIPHYER}/main.nf ${PREFIX}/bin/main.nf