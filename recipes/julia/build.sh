#!/bin/bash

# Copy everything but LICENSE.md
cp --archive --target-directory=$PREFIX ${PWD}/*/

# Configure juliarc to use conda environment
cat "${RECIPE_DIR}/juliarc.jl" >> "${PREFIX}/etc/julia/juliarc.jl"
