#!/bin/sh

pushd nasp/nasptool
go build -o ../nasptool_linux_64
popd

$PYTHON -m pip install --no-deps --ignore-installed --no-cache-dir -vvv .
