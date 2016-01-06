#!/bin/bash

cd $SRC_DIR/

# PYTHON_VERSION=`python -c "import sys;t='{v[0]}'.format(v=list(sys.version_info[:2]));sys.stdout.write(t)";`
# if [[ $PYTHON_VERSION = 3 ]]; then
#     pythonScripts=`find ./ws4py -type f -name "*.py"`
#     for i in $pythonScripts; do 2to3 $SRC_DIR/$i -w --no-diffs; done
# fi

$PYTHON setup.py install

