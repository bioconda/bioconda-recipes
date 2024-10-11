#!/bin/bash

# configure
./configure

# copy the source code to the build directory
SFOLD_DIR=${PREFIX}
mkdir -p ${SFOLD_DIR}
cp -r bin ${SFOLD_DIR}
cp -r lib ${SFOLD_DIR}
cp -r param ${SFOLD_DIR}
cp -r STarMir ${SFOLD_DIR}

# modify the sfoldenv file
sed -i "s|SFOLDDIR=.*|SFOLDDIR=${SFOLD_DIR}|g" sfoldenv
cp sfoldenv ${SFOLD_DIR}/sfoldenv