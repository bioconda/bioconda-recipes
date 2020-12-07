#!/bin/bash

cmake -DCMAKE_BUILD_TYPE=Release -G "CodeBlocks - Unix Makefiles" .
cmake -DCMAKE_PREFIX_PATH=`python -c 'import torch;print(str(torch.utils.cmake_prefix_path) + "/Torch")'`
cmake --build ./cmake-build-release --target Balrog -- -j 3
make install