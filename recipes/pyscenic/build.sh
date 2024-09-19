#!/bin/bash
set -ex

if [ -z "${PYTHON}" ]; then
  PYTHON=$(which python)
fi


pushd ${SRC_DIR}/pyscenic-0.12.1
${PYTHON} -m pip install . --use-pep517 --no-deps --ignore-installed -vv
popd

