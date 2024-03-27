#!/bin/bash -e

echo Removing DIVAnd Julia package...
julia -e "using Pkg; Pkg.rm(\"DIVAnd\")"

