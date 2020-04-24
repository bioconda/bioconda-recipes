#!/usr/bin/env bash

export CGO_ENABLED=0

go get -u github.com/golang/dep/cmd/dep
cd "$GOPATH/src/github.com/evolbioinfo/gotree"
dep ensure
go build -o ${PREFIX}/bin/gotree -ldflags "-X github.com/evolbioinfo/gotree/version.Version=${PKG_VERSION}" github.com/evolbioinfo/gotree

# Gotree test data
cp -r tests/data $PREFIX/gotree_test_data

# Gotree test script
echo "#!/usr/bin/env bash" > $PREFIX/bin/gotree_test.sh
sed 's+GOTREE=./gotree+GOTREE=gotree+g' test.sh \
    | sed "s+TESTDATA=\"tests/data\"+TESTDATA=\$(dirname \$0)/../gotree_test_data/+g" \
    >> $PREFIX/bin/gotree_test.sh
chmod a+x $PREFIX/bin/gotree_test.sh
