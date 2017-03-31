#!/bin/sh

chmod u+x **/*.sh

bash ./compile.sh

cp output/bazel $PREFIX/bin/
