#!/bin/bash

set -xe

mkdir -p ${PREFIX}/bin
mkdir -p ${SP_DIR}

cp -f grampa.py ${PREFIX}/bin
chmod 0755 ${PREFIX}/bin/grampa.py
cp -f ${PREFIX}/bin/grampa.py ${PREFIX}/bin/grampa
chmod 0755 ${PREFIX}/bin/grampa
mkdir -p ${SP_DIR}
cp -Rf grampa_lib ${SP_DIR}/grampa_lib