#!/bin/bash

make CPPFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib" install_prefix=$PREFIX install
