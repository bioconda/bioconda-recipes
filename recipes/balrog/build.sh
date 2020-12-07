#!/bin/bash

mkdir build
cd build
export Torch_DIR=`python -c 'import torch;print(torch.utils.cmake_prefix_path)'`
cmake --build . --target Balrog -- -j 3
make install