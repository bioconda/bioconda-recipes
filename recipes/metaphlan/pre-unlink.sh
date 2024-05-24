#!/bin/bash

PYTHON_INSTALL_DIR=$(python -c "import site; print(site.getsitepackages()[0])")

rm -rf $PYTHON_INSTALL_DIR/metaphlan                                   
