#!/bin/bash

cd ${SRC_DIR}
sed -i -e "s:~:\$\${PREFIX}:g" Makefile

cd ${PREFIX}/include
ln -s jellyfish-2.2.10/jellyfish jellyfish

cd ${SRC_DIR}
make

mkdir -p ${PREFIX}/bin
cp howdesbt ${PREFIX}/bin

chmod +x ${PREFIX}/bin/howdesbt
