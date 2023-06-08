#!/bin/bash

set -ex

# debug: show available tool chains
./gradlew -q javaToolchains


# TODO with "runtime" the software is only built
# if removed also tests are executed, some of them
# fail unfortunately
./gradlew runtime


mkdir -p "$PREFIX"
cp -rv build/install/MZmine/* "$PREFIX"

# for those the don't like capital letters in commands
ln -fs "$PREFIX"/bin/MZmine "$PREFIX"/bin/mzmine
