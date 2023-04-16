#!/bin/bash

set -ex

# TODO with "runtime" the software is only built
# if removed also tests are executed, some of them
# fail unfortunately
./gradlew runtime


mkdir -p "$PREFIX"
cp -rv build/install/MZmine/* "$PREFIX"
ln -fs "$PREFIX"/bin/MZmine "$PREFIX"/bin/mzmine

