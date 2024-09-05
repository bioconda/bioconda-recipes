#!/bin/bash
set -ex

if [ -z "${PYTHON}" ]; then
  PYTHON=$(which python)
fi

for package in arboreto-0.1.6 interlap-0.2.7 multiprocessing_on_dill-3.5.0a4 ctxcore-0.2.0; do
  pushd ${SRC_DIR}/${package}
  ${PYTHON} -m pip install . --use-pep517 --no-deps --ignore-installed -vv
  popd
done


pushd ${SRC_DIR}/pyscenic-0.12.1
${PYTHON} -m pip install . --use-pep517 --no-deps --ignore-installed -vv
popd
