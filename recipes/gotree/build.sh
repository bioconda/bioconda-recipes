#!/bin/bash

export CGO_ENABLED=0
export GOPATH=$PWD
export GOCACHE=$PWD/.cache/

mkdir -p "${GOCACHE}"
mkdir -p "${PREFIX}/bin"

cd src/github.com/evolbioinfo/${PKG_NAME}

make all -j"${CPU_COUNT}"

install -v -m 0755 gotree "${PREFIX}/bin"

#go get .
#go build -o ${PREFIX}/bin/${PKG_NAME} -ldflags "-X github.com/evolbioinfo/${PKG_NAME}/cmd.Version=${PKG_VERSION}" github.com/evolbioinfo/${PKG_NAME}
#go test github.com/evolbioinfo/${PKG_NAME}/...

# Gotree test data
cp -rf tests/data $PREFIX/gotree_test_data

# Gotree test script
echo "#!/usr/bin/env bash" > $PREFIX/bin/gotree_test.sh
sed -i.bak 's+GOTREE=./gotree+GOTREE=gotree+g' test.sh \
    | sed -i.bak "s+TESTDATA=\"tests/data\"+TESTDATA=\$(dirname \$0)/../gotree_test_data/+g" \
    >> $PREFIX/bin/gotree_test.sh
chmod a+x $PREFIX/bin/gotree_test.sh
