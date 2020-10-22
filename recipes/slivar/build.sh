#!/bin/sh
set -eu -o pipefail

VERSION="0.1.13"
PSLIVAR_SHA256SUM="00ae0b0ca141af57aea7900183ef9ff0d2b8e1147a9d5ec6e0f8a4147ab40ce8"

mkdir -p $PREFIX/bin
chmod a+x slivar
cp slivar $PREFIX/bin/slivar

curl -L -s -o pslivar https://github.com/brentp/slivar/releases/download/v${VERSION}/pslivar
sha256sum pslivar | grep ${PSLIVAR_SHA256SUM}
chmod a+x pslivar
cp pslivar $PREFIX/bin/pslivar
