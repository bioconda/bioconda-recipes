#!/bin/bash

# The VERSION file is mistaken for a C++20 version header file
# The patch does not rename the VERSION file on OSX, so we rename it here
mv VERSION{,.txt} || true

make prefix="${PREFIX}" install

cp -r scripts "${PREFIX}/bin/"