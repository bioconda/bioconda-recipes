#!/bin/bash

set -ex

# debug: show available tool chains
./gradlew -q javaToolchains
./gradlew --debug --stacktrace --exclude-task test

mkdir -p "$PREFIX"
cp -rv build/install/MZmine/* "$PREFIX"

# for those the don't like capital letters in commands
ln -fs "$PREFIX"/bin/MZmine "$PREFIX"/bin/mzmine

# MZmine does not run without --enable-preview
# .. so we sneek in in the command line
sed -i -e 's/exec "$JAVACMD" "$@"/exec "$JAVACMD" --enable-preview "$@"/' "$PREFIX"/bin/MZmine

