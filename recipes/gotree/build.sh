#!/usr/bin/env bash

export CGO_ENABLED=0
export GOPATH=$PWD
export GOCACHE=$PWD/.cache/

mkdir -p $GOCACHE
cd src/github.com/evolbioinfo/${PKG_NAME}
go get .
go build -o ${PREFIX}/bin/${PKG_NAME} -ldflags "-X github.com/evolbioinfo/${PKG_NAME}/version.Version=${PKG_VERSION}" github.com/evolbioinfo/${PKG_NAME}
go test github.com/evolbioinfo/${PKG_NAME}/...

# Gotree test data
cp -r tests/data $PREFIX/gotree_test_data

# Gotree test script
echo "#!/usr/bin/env bash" > $PREFIX/bin/gotree_test.sh
sed 's+GOTREE=./gotree+GOTREE=gotree+g' test.sh \
    | sed "s+TESTDATA=\"tests/data\"+TESTDATA=\$(dirname \$0)/../gotree_test_data/+g" \
    >> $PREFIX/bin/gotree_test.sh
chmod a+x $PREFIX/bin/gotree_test.sh
