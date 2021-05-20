#!/bin/bash

# define and make a src folder
VARIPHYER="${PREFIX}/share/${PKG_NAME}"
mkdir -p ${VARIPHYER}

# copy everything into src folder
cp -r ./* ${VARIPHYER}

chmod 777 ${VARIPHYER}/variphyer

#make a bin folder
mkdir -p ${PREFIX}/bin 

ln -s ${VARIPHYER}/variphyer ${PREFIX}/bin/variphyer