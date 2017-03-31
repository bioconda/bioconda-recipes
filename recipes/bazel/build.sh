#!/bin/bash

chmod +x ./compile.sh
chmod +x ./tools/build_rules/gensrcjar.sh

./compile.sh

cp output/bazel $PREFIX/bin/