#!/bin/bash -e

echo Installing DIVAnd Julia package...
julia -e "using Pkg; Pkg.add(name=\"DIVAnd\", version=\"$PKG_VERSION\")"

