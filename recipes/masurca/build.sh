#!/usr/bin/env bash

set -x -e

export BOOST_ROOT=${PREFIX}
export DEST=${PREFIX}
export PERL_EXT_CPPFLAGS="-D_REENTRANT -D_GNU_SOURCE -fwrapv -fno-strict-aliasing -pipe -fstack-protector -I/usr/local/include"
export PERL_EXT_LDFLAGS="-shared -O2 -L/usr/local/lib -fstack-protector"
export LDFLAGS="-L${PREFIX}/lib"
export CPATH=${PREFIX}/include

URL="https://github.com/alekseyzimin/masurca/releases/download/${PKG_VERSION}/MaSuRCA-${PKG_VERSION}.tar.gz"
SHA256='3d3df9276d221551fd190cad3d037d56ce70691592cb28198e7bffc7c07760b2'
TAR_FILE="${PKG_NAME}-${PKG_VERSION}.tar.gz"
curl -Lo "${TAR_FILE}" "${URL}"
openssl sha256 "${TAR_FILE}" | grep -q "${SHA256}"
tar -xzf "${TAR_FILE}" --strip-components=1
rm "${TAR_FILE}"

./install.sh
