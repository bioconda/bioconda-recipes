#!/bin/bash

cmake -DCMAKE_BUILD_TYPE=Release -G "CodeBlocks - Unix Makefiles" ..
cmake -DCMAKE_MODULE_PATH=`python -c 'import torch;print(torch.utils.cmake_prefix_path)'` ..
cmake --build ./cmake-build-release --target Balrog -- -j 3
make install