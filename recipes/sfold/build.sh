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
sed -i "s|SFOLDDIR=.*|SFOLDDIR=${SFOLD_DIR}|g" ${SFOLD_DIR}/sfoldenv
sed -i "s:/usr/bin/perl:/usr/bin/env perl:" ${SFOLD_DIR}/STarMir/*.pl
sed -i "s:/bin/perl:/bin/env perl:" ${SFOLD_DIR}/STarMir/*.pl
sed -i "s:/usr/bin/perl:/usr/bin/env perl:" ${SFOLD_DIR}/STarMir/starmir-param/*.pl
sed -i "s:/usr/bin/perl:/usr/bin/env perl:" ${SFOLD_DIR}/bin/*.pl
