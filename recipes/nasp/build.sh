#!/bin/sh

# Remove when go1.11 is available
go get -u golang.org/x/vgo

pushd nasp/nasptool
echo 'module "github.com/TGenNorth/nasp"' > go.mod
$(go env GOPATH)/bin/vgo build -o ../nasptool_linux_64
popd

$PYTHON -m pip install --no-deps --ignore-installed --no-cache-dir -vvv .
