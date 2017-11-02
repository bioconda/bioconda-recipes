#!/bin/sh

./configure --prefix=$PREFIX
make

# Run tests on Linux, on OS X tests 58 and 59 are broken
if [ "$(uname)" == "Linux" ]; then
    ./testit.sh
fi

make install
