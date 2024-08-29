#!/bin/bash
set -ex

if [ -z "${PYTHON}" ]; then
  PYTHON=$(which python)
fi

pushd ${SRC_DIR}/pyscenic
${PYTHON} -m pip install . --no-deps --ignore-installed -vv
popd
  
  ${PYTHON} -m pip install --use-pep517 -vv --no-deps .
  popd
done
