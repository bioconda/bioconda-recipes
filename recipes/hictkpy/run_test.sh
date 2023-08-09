#!/usr/bin/env bash

"$PYTHON" -m site

ls -lah /opt/conda/conda-bld/hictkpy*
ls -lah /opt/conda/conda-bld/hictkpy*/_test_env*
ls -lah /opt/conda/conda-bld/hictkpy*/_test_env*/lib/python3.10/site-packages
ls -lah /opt/conda/conda-bld/hictkpy*/_test_env*/lib/python3.10/site-packages/hictkpy

"$PYTHON" -c 'import hictkpy; print(hictkpy.__version__)'

"$PYTHON" -m pytest test
