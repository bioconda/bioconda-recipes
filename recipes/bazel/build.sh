#!/bin/bash

chmod u+x **/*.sh

./compile.sh

cp output/bazel $PREFIX/bin/