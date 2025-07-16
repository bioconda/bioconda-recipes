#!/bin/bash
set -ex

mkdir -p "${PREFIX}"

# debug: show available tool chains
./gradlew -q javaToolchains
./gradlew --exclude-task test --debug --stacktrace jpackage

cp -rfv build/jpackage/mzmine/* "${PREFIX}"

# MZmine does not run without --enable-preview
# .. so we sneek in in the command line
sed -i.bak -e 's/exec "$JAVACMD" "$@"/exec "$JAVACMD" --enable-preview "$@"/' "${PREFIX}/bin/mzmine"
rm -rf "${PREFIX}/bin/*.bak"
