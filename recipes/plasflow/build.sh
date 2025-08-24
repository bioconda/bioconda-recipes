#!/bin/bash

# # install tensorflow version 0.10.0rc0
# pip install --no-deps --ignore-installed --no-cache-dir  tensorflow/tensorflow-0.10.0rc0-cp35-cp35m-linux_x86_64.whl


# install PlasFlow
$PYTHON -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv

ls -la

# copy models
cp -r -v PlasFlow/models "$PREFIX/bin/"

ls -la "$PREFIX/bin/"

