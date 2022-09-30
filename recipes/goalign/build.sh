#!/usr/bin/env bash

export CGO_ENABLED=0
export GOPATH=$PWD
export GOCACHE=$PWD/.cache/

mkdir -p $GOCACHE
cd src/github.com/evolbioinfo/${PKG_NAME}
go get .
go build -o ${PREFIX}/bin/${PKG_NAME} -ldflags "-X github.com/evolbioinfo/${PKG_NAME}/version.Version=${PKG_VERSION}" github.com/evolbioinfo/${PKG_NAME}
go test github.com/evolbioinfo/${PKG_NAME}/...

# Goalign test data
cp -r tests/data $PREFIX/goalign_test_data

# Goalign test script
echo "#!/usr/bin/env bash" > $PREFIX/bin/goalign_test.sh
sed 's+GOALIGN=./goalign+GOALIGN=goalign+g' test.sh \
    | sed "s+TESTDATA=\"tests/data\"+TESTDATA=\$(dirname \$0)/../goalign_test_data/+g" \
    | sed "s+tar -xzf boot.tar.gz+gunzip -c boot.tar.gz | tar xf -+g" \
    >> $PREFIX/bin/goalign_test.sh
chmod a+x $PREFIX/bin/goalign_test.sh
