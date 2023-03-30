#! /bin/sh

export GOPATH="$( pwd )"
export GO111MODULE=auto

module_path="$( go env GOPATH )"/src/github.com/involucro/involucro/cmd/involucro
GOBIN="$( go env GOBIN )" \
  go build -o $PREFIX/bin/involucro \
  -ldflags="-s -X github.com/involucro/involucro/app.version=${PKG_VERSION}" \
  "${module_path}"


# Since https://github.com/conda/conda-build/issues/4121, conda build supports
# collected license files via directories, so we first download all vendor
# dependencies and use go-licenses to save license to "3rd_party_license"
cd "$( go env GOPATH )"/src/github.com/involucro/involucro
go mod init github.com/involucro/involucro
go mod tidy
go mod download
go mod vendor
go-licenses save ./cmd/involucro --save_path=3rd_party_license
