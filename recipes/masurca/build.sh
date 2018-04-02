#!/usr/bin/env bash

set -x -e

export BOOST_ROOT=${PREFIX}

URL="https://github.com/alekseyzimin/masurca/files/1668918/MaSuRCA-${PKG_VERSION}.tar.gz"
SHA256='759d5b0411b048d996df1ca6daadf1cc49ff88f4436a21cd81d7f191a8bd80b0'
TAR_FILE="${PKG_NAME}-${PKG_VERSION}.tar.gz"
curl -Lo "${TAR_FILE}" "${URL}"
openssl sha256 "${TAR_FILE}" | grep -q "${SHA256}"
tar -xzf "${TAR_FILE}" --strip-components=1
rm "${TAR_FILE}"

./install.sh
