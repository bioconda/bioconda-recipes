#!/bin/bash
$PYTHON setup.py install
chmod -R 777 $PREFIX
chmod -R 777 $RECIPE_DIR
chmod -R 777 $SP_DIR
chmod -R 777 $SRC_DIR
