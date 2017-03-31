#!/bin/bash

chmod +x ./compile.sh
chmod +x ./tools/build_rules/gensrcjar.sh
chmod +x ./link_dynamic_library.sh

./compile.sh

cp output/bazel $PREFIX/bin/