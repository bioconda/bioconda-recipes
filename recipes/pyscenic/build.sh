#!/bin/bash
set -ex

# Compile and install the sources in the order required
for package in arboreto-0.1.6 interlap-0.2.7 multiprocessing_on_dill-3.5.0a4 ctxcore-0.2.0; do
  pushd ${SRC_DIR}/${package}
  ${PYTHON} -m pip install . --no-deps --ignore-installed -vv
  popd
done

# Finally, install the main package
pushd ${SRC_DIR}/pyscenic-0.12.1
${PYTHON} -m pip install . --no-deps --ignore-installed -vv
popd
