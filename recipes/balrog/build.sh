#!/bin/bash

mkdir build
cd build
cmake -DCMAKE_MODULE_PATH=`python -c 'import torch;print(torch.utils.cmake_prefix_path)'` ..
cmake --build . --target Balrog -- -j 3
make install