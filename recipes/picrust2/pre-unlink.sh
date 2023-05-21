#!/bin/bash

PYTHON_INSTALL_DIR=`python -c "import site; print(site.getsitepackages()[0])"`

rm -r $PYTHON_INSTALL_DIR/picrust2/default_files
