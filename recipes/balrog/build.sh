#!/bin/bash

mkdir build
cd build
export Torch_DIR=`python -c 'import torch;import os;print(os.path.join(torch.utils.cmake_prefix_path, "Torch"))'`
cmake --build . --target Balrog -- -j 3
make install