#!/bin/bash -euo

mkdir -p ${PREFIX}/bin

${PYTHON} -m pip install . -vvv --no-deps --no-build-isolation

chmod +rx ${SP_DIR}/Monopogen.py
cp ${SP_DIR}/Monopogen.py ${PREFIX}/bin
