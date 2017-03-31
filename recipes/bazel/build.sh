#!/bin/sh

scl enable devtoolset-4 bash

bash ./compile.sh

cp output/bazel $PREFIX/bin/
