#!/bin/bash
set -ex

mkdir -p "$PREFIX"

# debug: show available tool chains
./gradlew -q javaToolchains
./gradlew --exclude-task test --debug --stacktrace build

cp -rv build/install/MZmine/* "$PREFIX"

# for those the don't like capital letters in commands
ln -fs "$PREFIX/bin/MZmine" "$PREFIX/bin/mzmine"

# MZmine does not run without --enable-preview
# .. so we sneek in in the command line
sed -i.bak -e 's/exec "$JAVACMD" "$@"/exec "$JAVACMD" --enable-preview "$@"/' "$PREFIX/bin/MZmine"
rm -rf "$PREFIX/bin/*.bak"
