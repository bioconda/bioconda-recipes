#!/bin/bash

setenv SHELL /bin/bash

bash ./compile.sh

cp output/bazel $PREFIX/bin/
