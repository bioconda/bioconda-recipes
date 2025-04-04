#!/bin/sh

pushd nasp/nasptool
echo 'module "github.com/TGenNorth/nasp"' > go.mod
go build -o ../nasptool_linux_64
popd

$PYTHON -m pip install --no-deps --ignore-installed --no-cache-dir -vvv .
