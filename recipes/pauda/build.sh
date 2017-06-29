#!/bin/sh
set -x -e

cp -rf pauda-1.0.1/bin $PREFIX
cp -rf pauda-1.0.1/data $PREFIX
cp -rf pauda-1.0.1/lib $PREFIX
chmod a+x $PREFIX/bin/pauda-run
chmod a+x $PREFIX/bin/pauda-build
