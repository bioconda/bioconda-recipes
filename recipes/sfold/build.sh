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
cp sfoldenv ${SFOLD_DIR}/sfoldenv
sed -i.bak "s|SFOLDDIR=.*|SFOLDDIR=${SFOLD_DIR}|g" ${SFOLD_DIR}/sfoldenv
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${SFOLD_DIR}/STarMir/*.pl
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${SFOLD_DIR}/STarMir/starmir-param/*.pl
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${SFOLD_DIR}/bin/*.pl

rm -rf ${SFOLD_DIR}/*.bak
rm -rf ${SFOLD_DIR}/STarMir/*.bak
rm -rf ${SFOLD_DIR}/STarMir/starmir-param/*.bak
rm -rf ${SFOLD_DIR}/bin/*.bak
