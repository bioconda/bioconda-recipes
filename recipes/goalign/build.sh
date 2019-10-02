#!/usr/bin/env bash

export CGO_ENABLED=0

go get -u github.com/golang/dep/cmd/dep
cd "$GOPATH/src/github.com/evolbioinfo/goalign"
dep ensure
go build -o ${PREFIX}/bin/goalign -ldflags "-X github.com/evolbioinfo/goalign/version.Version=${PKG_VERSION}" github.com/evolbioinfo/goalign

# Goalign test data
cp -r tests/data $PREFIX/goalign_test_data

# Goalign test script
sed 's+GOALIGN=./goalign+GOALIGN=goalign+g' test.sh | sed "s+TESTDATA=\"tests/data\"+TESTDATA=${PREFIX}/goalign_test_data/+g"  > $PREFIX/bin/goalign_test.sh
chmod a+x $PREFIX/bin/goalign_test.sh
