#!/bin/sh

cd src
make -j ${CPU_COUNT} && \
install RRIKinDP "$CONDA_PREFIX/bin"


