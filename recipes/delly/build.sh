#!/bin/sh

make CXX="$CXX" all
make prefix="$PREFIX" install
