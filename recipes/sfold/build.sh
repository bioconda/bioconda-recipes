#!/bin/bash

# configure
./configure

# copy the source code to the build directory
SFOLD_DIR=${PREFIX}/bin/sfold_dir
mkdir -p ${SFOLD_DIR}
cp -r bin ${SFOLD_DIR}
cp -r lib ${SFOLD_DIR}
cp -r param ${SFOLD_DIR}
cp -r STarMir ${SFOLD_DIR}

# modify the sfoldenv file
sed -i "s|SFOLDDIR=.*|SFOLDDIR=${SFOLD_DIR}|g" sfoldenv
sed -i "s|PATH_AWK=.*|PATH_AWK=${PREFIX}/bin/awk|g" sfoldenv
sed -i "s|PATH_GREP=.*|PATH_GREP=${PREFIX}/bin/grep|g" sfoldenv
sed -i "s|PATH_PERL=.*|PATH_PERL=${PREFIX}/bin/perl|g" sfoldenv
sed -i "s|PATH_R=.*|PATH_R=${PREFIX}/bin/R|g" sfoldenv

cp sfoldenv ${SFOLD_DIR}/sfoldenv

# modify sfold
sed -i "s|LOC=\`dirname \$0\`|LOC=${SFOLD_DIR}/sfoldenv|g" ${SFOLD_DIR}/bin/sfold
sed -i "s|. \$LOC/../sfoldenv|. \$LOC|g" ${SFOLD_DIR}/bin/sfold

# simlink the sfold
ln -s ${SFOLD_DIR}/bin/sfold ${PREFIX}/bin/sfold