#!/bin/bash

set -ex

# TODO use patch
sed -i -e 's@// installerType = "deb"@installerType = "rpm"@; s@vendor = JvmVendorSpec.ADOPTIUM@// vendor = JvmVendorSpec.ADOPTIUM@' build.gradle


# debug: show available tool chains
./gradlew -q javaToolchains

./gradlew --debug --stacktrace --exclude-task test


mkdir -p "$PREFIX"
cp -rv build/install/MZmine/* "$PREFIX"

# for those the don't like capital letters in commands
ln -fs "$PREFIX"/bin/MZmine "$PREFIX"/bin/mzmine

sed -i -e 's/exec "$JAVACMD" "$@"/exec "$JAVACMD" --enable-preview "$@"/' "$PREFIX"/bin/MZmine

