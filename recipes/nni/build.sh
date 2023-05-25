#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

export NNI_RELEASE=${PKG_VERSION}
${PYTHON} setup.py build_ts
${PYTHON} setup.py bdist_wheel
pip install -e . --user --use-pep517 -vv
