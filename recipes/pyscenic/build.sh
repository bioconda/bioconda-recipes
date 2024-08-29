#!/bin/bash
set -ex

if [ -z "${PYTHON}" ]; then
  PYTHON=$(which python)
fi

pushd ${SRC_DIR}/pyscenic
${PYTHON} -m pip install . --no-deps --ignore-installed -vv
popd

for package in aiohttp arboreto-0.1.6 frozendict-2.1.0 interlap-0.2.7 multiprocessing_on_dill-3.5.0a4 ctxcore-0.2.0 loompy-3.0.6
do
  pushd ${SRC_DIR}/${package}
  
  if [ "$package" == "arboreto-0.1.6" ]; then
    if [ ! -f requirements.txt ]; then
      echo "Creating requirements.txt for arboreto"
      echo "dask[complete]" > requirements.txt
      echo "distributed" >> requirements.txt
      echo "numpy>=1.16.5" >> requirements.txt
      echo "pandas" >> requirements.txt
      echo "scikit-learn" >> requirements.txt
      echo "scipy" >> requirements.txt
    fi
  fi
  
  ${PYTHON} -m pip install --use-pep517 -vv --no-deps .
  popd
done
