#!/bin/bash

set -ex

grep -v "vendor = JvmVendorSpec.ADOPTIUM" build.gradle > tmp
mv tmp build.gradle

# debug: show available tool chains
./gradlew -q javaToolchains


./gradlew


mkdir -p "$PREFIX"
cp -rv build/install/MZmine/* "$PREFIX"

# for those the don't like capital letters in commands
ln -fs "$PREFIX"/bin/MZmine "$PREFIX"/bin/mzmine
