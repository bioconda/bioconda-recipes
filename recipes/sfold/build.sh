#!/bin/bash

# Run configure script to setup build
# cp ${RECIPE_DIR}/configure ./configure
sed -i "s|ac_default_prefix=\$PWD|ac_default_prefix=\${PREFIX}|g" configure
sed -i "s|SFOLDDIR=@abs_top_builddir@|SFOLDDIR=\${PREFIX}|g" sfoldenv.in

./configure

cp -r bin/* ${PREFIX}/bin
cp -r lib/* ${PREFIX}/lib
cp -r param ${PREFIX}
cp -r STarMir ${PREFIX}
cp sfoldenv ${PREFIX}