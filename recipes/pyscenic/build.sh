#!/bin/bash
set -e

pushd ${SRC_DIR}/arboreto-0.1.6
if [ ! -f requirements.txt ]; then
    echo "dask[complete]" > requirements.txt
    echo "distributed" >> requirements.txt
    echo "numpy>=1.16.5" >> requirements.txt
    echo "pandas" >> requirements.txt
    echo "scikit-learn" >> requirements.txt
    echo "scipy" >> requirements.txt
fi
${PYTHON} -m pip install . --no-deps --ignore-installed -vv
popd

pushd ${SRC_DIR}/interlap-0.2.7
${PYTHON} -m pip install . --no-deps --ignore-installed -vv
popd

pushd ${SRC_DIR}/multiprocessing_on_dill-3.5.0a4
${PYTHON} -m pip install . --no-deps --ignore-installed -vv
popd

pushd ${SRC_DIR}/ctxcore-0.2.0
${PYTHON} -m pip install . --no-deps --ignore-installed -vv
popd

pushd ${SRC_DIR}/pyscenic-0.12.1
${PYTHON} -m pip install . --no-deps --ignore-installed -vv
popd
