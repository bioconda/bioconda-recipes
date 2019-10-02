#!/usr/bin/env bash

export CGO_ENABLED=0

go get -u github.com/golang/dep/cmd/dep
cd "$GOPATH/src/github.com/evolbioinfo/goalign"
dep ensure
go build -o ${PREFIX}/bin/goalign -ldflags "-X github.com/evolbioinfo/goalign/version.Version=${PKG_VERSION}" github.com/evolbioinfo/goalign

# Goalign test data
cp -r tests/data $PREFIX/goalign_test_data

# Goalign test script
echo "#!/usr/bin/env bash" > $PREFIX/bin/goalign_test.sh
sed 's+GOALIGN=./goalign+GOALIGN=goalign+g' test.sh \
    | sed "s+TESTDATA=\"tests/data\"+TESTDATA=\$(dirname \$0)/../goalign_test_data/+g" \
    | sed "s+tar -xzf boot.tar.gz+gunzip -c boot.tar.gz | tar xf -+g" \
    >> $PREFIX/bin/goalign_test.sh
chmod a+x $PREFIX/bin/goalign_test.sh
